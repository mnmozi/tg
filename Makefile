.DEFAULT_GOAL := check
MODULES := $(shell find modules -name main.tf -printf '%h\n' | sort -u)

.PHONY: check fmt fmt-check validate lint hclfmt

check: fmt-check validate lint hclfmt ## run everything CI runs

fmt: ## format Terraform and Terragrunt files in place
	terraform fmt -recursive modules
	terragrunt hcl fmt

fmt-check:
	terraform fmt -check -recursive -diff modules
	terragrunt hcl fmt --check

validate: ## terraform validate every module (no backend, no AWS credentials needed)
	@set -e; for m in $(MODULES); do \
	  echo "== $$m"; \
	  terraform -chdir=$$m init -backend=false -input=false >/dev/null; \
	  terraform -chdir=$$m validate; \
	done

lint: ## tflint every module
	tflint --init
	@set -e; for m in $(MODULES); do echo "== $$m"; tflint --chdir=$$m --config=$(CURDIR)/.tflint.hcl --minimum-failure-severity=error; done

hclfmt: ## check Terragrunt HCL formatting
	terragrunt hcl fmt --check
