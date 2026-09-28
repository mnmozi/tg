# Upgrade notes: AWS provider 6.x, upstream majors, root.hcl

This change set moves the repository to the current toolchain and fixes the
configuration bugs found in the review. Nothing here has been applied against
AWS; run `terragrunt plan` on every unit and read the plan before applying.

## Toolchain

| Component                    | Before        | After         |
|------------------------------|---------------|---------------|
| Terraform                    | unpinned      | 1.16.4        |
| Terragrunt                   | unpinned      | 1.1.6         |
| hashicorp/aws                | 5.30 / 5.89   | `~> 6.66`     |
| terraform-aws-modules/vpc    | 5.8.1         | 6.7.3         |
| terraform-aws-modules/rds    | 6.6.0         | 7.2.2         |
| terraform-aws-modules/rds-aurora | 9.11.0    | 10.4.1        |
| terraform-aws-modules/ecs    | 5.12.0        | 7.6.1         |
| terraform-aws-modules/eks    | ~> 20.31      | ~> 21.26      |
| terraform-aws-modules/s3-bucket | unpinned   | 5.16.1        |
| nozaq/remote-state-s3-backend | unpinned     | 1.6.1         |

`mise install` (or tfenv/tgswitch reading `.terraform-version` and
`.terragrunt-version`) installs the pinned tools.

## What changed structurally

- Root configs are now `root.hcl`; every unit includes
  `find_in_parent_folders("root.hcl")`. Terragrunt 1.x warns on the old
  `terragrunt.hcl`-as-root pattern.
- `root.hcl` generates `provider.tf`; modules no longer contain a
  `provider "aws"` block. Modules only declare `required_providers`.
- Unit sources use `${get_repo_root()}/modules//<module>`. The `//` makes
  Terragrunt copy the whole `modules/` tree into the cache so modules can
  reference siblings by relative path (`../ami-role`). The previous
  `github.com/mnmozi/tg//modules/...` references pulled unpinned `main` on
  every run.
- Every module is `main.tf` + `variables.tf` + `outputs.tf` + `versions.tf`.
- `modules/aws_appautoscaling_policy` moved to `modules/ecs/04-autoscaling`.

## Expected plan output on already-deployed units

The following are behavioural changes you should see in a plan. Anything
else needs a look before apply.

### All units

- Tag additions on security groups (project/component/environment/owner)
  and the private hosted zone: the wrappers previously dropped
  `required_tags`.

### 00-infra/00-vpc

- `cidr` is now passed explicitly as `10.1.0.0/16`. The old inputs
  `cidr_b_block`/`cidr_prefix` were never declared by the module, so the
  module default was deployed. Confirm the plan shows no VPC replacement.
- Public and private subnet slices were swapped in the module. With the
  default of one public and one private subnet per AZ this makes no
  difference, but check the plan.

### 00-infra/01-nat-gateway

- The NAT gateway is now placed in `public_subnets[0]`. A public NAT gateway
  must sit in a subnet with an internet gateway route; the old config used
  `private_subnets[0]`. If a NAT gateway already exists it will be replaced.
- The unit passed `route_table_id` (singular) which the module never read,
  so no default route was ever created. It now passes
  `route_table_ids = private_route_table_ids`: expect new `aws_route`
  resources.

### 01-yozo/08-db (RDS Postgres)

- Upstream v7 drops `password` in favour of write-only `password_wo`.
  The plan shows a master password update with the same value; the password
  is no longer stored in state. Bump `password_version` after rotating the
  secret.
- `backup_retention_period = 3` now actually applies (it was previously
  ignored); expect an in-place change from the AWS default.
- The final snapshot name no longer contains `timestamp()`, which removes
  the permanent diff.

### 01-yozo/08-aurora-db (Aurora MySQL)

- Same write-only password change as above (`master_password_wo`).
- `publicly_accessible` and `performance_insights_enabled` are now applied
  per instance. Parameter groups are created from `cluster_parameter_group`
  and `db_parameter_group` objects with the same names as before.
- The HCL had `publicly_accessible` twice in one object; that is a parse
  error in Terragrunt and has been removed.
- Port 5432 on an aurora-mysql cluster is kept because that is how the
  cluster was created.

### 00-common/ecs-clusters/yozo-applications

- Upstream ECS v7 requires `cluster_capacity_providers`; the wrapper derives
  it from `fargate_capacity_providers`. Expect no resource replacement.

### 01-yozo/01-backend and 02-sidekiq task definitions

- The task role policy shrinks to the four `ssmmessages:*Channel` actions
  ECS Exec needs. The unrelated `ssm:*`/`ec2messages:*` statements were also
  removed from the execution role. New task definition revisions will be
  created.
- Sidekiq's service pointed at `../02-sg`, which does not exist; it now uses
  `../00-sg`.

### 01-yozo/01-backend/05-auto-scaling

- The unit read `dependency.service.outputs.service`, an output that did
  not exist. It now uses the new `name`/`cluster_name` outputs. Scheduled
  actions were renamed (`scale-in`/`scale-out` were inverted) and will be
  recreated.

### 01-yozo/01-backend/10-cloudfront/03-route53-record

- Record name fixed from `sstaging-yozo` to `staging-yozo`.

### 00-common/lbs/01-external-lb/01-lb

- The unit passed `certificate_arn`, which the module did not declare, and
  omitted the required `certificates` map. It now uses the new
  `listener_certificate_arns` input.

### 00-common/ecs-clusters/capacity-providers/00-m6i.large/*

- These units could never have been applied (they included a `root.hcl`
  that did not exist and referenced an undeclared `dependency.vpc`). They
  are now consistent and tagged `yozo/ecs-m6i-large`; the launch template
  user data reads the cluster name from the cluster unit.

### modules/eks

- No live unit uses it. The wrapper keeps its `cluster_*` input names and
  maps them to the un-prefixed names of upstream v21. If you have an EKS
  cluster on v20 elsewhere, read
  `docs/UPGRADE-21.0.md` in the upstream repo first: node group defaults
  (AMI type, IMDS hop limit, monitoring) changed.

## Things deliberately not changed

- Real account IDs, certificate ARNs, domains and secret names stay in the
  live tree. Consider moving them to SSM/Secrets Manager lookups or a
  private repo if this one stays public.
- `root.hcl` still carries `<env>`, `<s3-bucket>` and `<kms-key>`
  placeholders; region is derived from the directory name.
- ElastiCache's subnet group name is still hard-coded because the VPC unit
  does not create ElastiCache subnets.
