# tg — Terragrunt modules and live infrastructure

Reusable Terraform modules for AWS plus the Terragrunt "live" tree that
deploys them. One repository, two halves:

```
modules/   Terraform modules (one directory per resource family)
live/      Terragrunt units, one directory per deployed thing
  <env>/<region>/root.hcl           shared config: state backend, provider, common inputs
  <env>/<region>/00-infra/...       VPC, NAT, private DNS
  <env>/<region>/10-applications/.. ECS clusters, services, databases, CDN
docs/      design specs and upgrade notes
```

## Toolchain

| Tool        | Version | Pinned in |
|-------------|---------|-----------|
| Terraform   | 1.16.4  | `.terraform-version`, `mise.toml` |
| Terragrunt  | 1.1.6   | `.terragrunt-version`, `mise.toml` |
| AWS provider| `~> 6.66` | every `modules/*/versions.tf` |
| tflint      | latest  | `mise.toml`, `.tflint.hcl` |

```sh
mise install          # installs the versions above
pre-commit install    # fmt / validate / tflint on every commit
make check            # what CI runs: fmt, validate, tflint, terragrunt hcl fmt
```

## How a unit works

```hcl
terraform {
  source = "${get_repo_root()}/modules//ecs/03-service"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "cluster" {
  config_path = "${get_parent_terragrunt_dir()}/10-applications/00-common/ecs-clusters/yozo-applications"
}

inputs = {
  cluster_name  = dependency.cluster.outputs.cluster_name
  required_tags = { project = "yozo", component = "application" }
}
```

- `root.hcl` generates `backend.tf` (S3 + KMS, key derived from the unit's
  path) and `provider.tf` (region). Modules do not contain provider blocks.
- `${get_repo_root()}/modules//<name>`: the `//` makes Terragrunt copy the
  whole `modules/` tree into `.terragrunt-cache`, so modules can reference
  siblings with relative paths (for example `../ami-role`).
- Every module takes `region`, `environment`, `required_tags`
  (`project` + `component`), `tags` and optional `owner`. Resource names
  default to `<environment>-<project>-<component>`.

## Conventions

- Module layout: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.
  `versions.tf` only declares `required_providers`.
- Modules that wrap `terraform-aws-modules/*` pin an exact upstream version.
- Directory numbering (`00-`, `01-`, …) is the intended apply order; it is
  documentation, Terragrunt orders by `dependency` blocks.
- Placeholders like `<env>`, `<s3-bucket>` and `<kms-key>` in `root.hcl`
  must be filled in per environment; region is read from the directory name.

## Bootstrapping a new environment

1. `modules/remote-state` creates the state bucket, KMS key and lock table.
   It is the only module that carries its own (replica) provider.
2. Copy `live/00-uat/eu-central-1/root.hcl`, fill the locals.
3. `terragrunt run --all plan` from the environment directory.

## Modules

| Module | What it creates |
|--------|-----------------|
| `vpc` | VPC, subnets (public/private/database/elasticache), optional NAT, private zone |
| `nat-gateway` | Standalone NAT gateway + default routes |
| `sg` | Security group with CIDR / SG-name / SG-id rules |
| `lb`, `tg`, `lr` | ALB, target group, listener rule |
| `ecs/00-ecr` … `ecs/04-autoscaling` | ECR repo, task definition (+ IAM roles), cluster, service, application autoscaling |
| `db`, `db-rds-aurora`, `elasticache` | RDS instance, Aurora cluster, Redis replication group |
| `eks`, `eks-pod-identity` | EKS cluster (upstream v21), pod identity role |
| `lambda`, `s3`, `ses`, `sns-email`, `ssm-parameter`, `acm-certificate` | Serverless and supporting services |
| `cloudfront/*`, `route53-*` | CDN distribution, cache policy, VPC origin, DNS |
| `ec2`, `ec2-keypair`, `lt`, `asg`, `ami-related/*`, `ami-role`, `policy-role` | EC2 building blocks and IAM roles |
| `remote-state` | State backend bootstrap |
| `dynatrace-aws-monitoring-role` | Cross-account role for Dynatrace |

See `docs/UPGRADE-2026-09.md` for the migration notes of the latest
toolchain upgrade.
