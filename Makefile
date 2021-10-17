.PHONY: help
help:
	@echo "Terraform makefile"

.PHONY: init
init:
	$(call terraform-cmd-env,init)
	
.PHONY: upgrade
upgrade:
	$(call terraform-cmd-env,init -upgrade)
	
.PHONY: plan
plan: fmt
	$(call terraform-cmd-env,plan)

.PHONY: apply
apply: validate fmt
	$(call terraform-cmd-env,apply)

.PHONY: destroy
destroy: validate
	$(call terraform-cmd-env,destroy)

.PHONY: output
output: fmt
	$(call terraform-cmd-env,output)
	
.PHONY: fmt
fmt: validate
	$(call terraform-cmd,fmt -recursive -list=true)

.PHONY: validate
validate:
	find roots -type f -name 'main.tf' -print -execdir $(call terraform-validate) \; | grep false && exit 1 || echo "Terraform is valid"

define terraform-validate
	sh -c "terraform validate; terraform validate -json | jq .valid"
endef

define terraform-cmd-env
	$(call read-variable) \
	pushd roots/$$env/; \
	$(call terraform-cmd,$(1)) \
	popd;
endef

define read-variable
	read -p "Environment: " env;
endef

define terraform-cmd
	terraform $(1);
endef