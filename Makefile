.PHONY: help
help:
	@echo "Terraform makefile"

.PHONY: init
init:
	$(call terraform-cmd,init)
	
.PHONY: upgrade
upgrade:
	$(call terraform-cmd,init -upgrade)
	
.PHONY: plan
plan: fmt build
	$(call terraform-cmd,plan)

.PHONY: apply
apply: validate fmt build
	$(call terraform-cmd,apply)
	
.PHONY: build
build:
	sh -c "cd toshl-email-autosync; make build-for-lambda"

.PHONY: destroy
destroy: validate
	$(call terraform-cmd,destroy)

.PHONY: output
output: fmt
	$(call terraform-cmd,output)
	
.PHONY: fmt
fmt: validate
	$(call terraform-cmd,fmt -recursive -list=true)

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
