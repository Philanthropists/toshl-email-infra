.PHONY: help
help:
	@echo "Terraform makefile"

.PHONY: refresh
refresh:
	$(call terraform-cmd,apply -auto-approve -replace=module.toshl-lambda.aws_lambda_function.sync)
	$(call terraform-cmd,apply -auto-approve -replace=module.toshl-lambda.aws_cloudwatch_event_target.check_schedule)

.PHONY: init
init:
	$(call terraform-cmd,init)

.PHONY: upgrade
upgrade:
	$(call terraform-cmd,init -upgrade)

.PHONY: plan
plan: fmt
	$(call terraform-cmd,plan)

.PHONY: apply
apply: fmt
	$(call terraform-cmd,apply)

.PHONY: destroy
destroy: validate
	$(call terraform-cmd,destroy)

.PHONY: output
output: fmt
	$(call terraform-cmd,output)

.PHONY: fmt
fmt: validate
	terraform fmt -recursive -list=true

.PHONY: validate
validate:
	find roots -type f -name 'main.tf' -print -execdir $(call terraform-validate) \; | grep false && exit 1 || echo "Terraform is valid"

define terraform-validate
	sh -c "terraform validate; terraform validate -json | jq .valid"
endef

define terraform-cmd
	pushd roots; \
	terraform $(1); \
	popd;
endef
