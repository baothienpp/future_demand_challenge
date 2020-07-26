######################################################################################
#### 					Terraform Makefile						                  ####
######################################################################################

.ONESHELL:
SHELL := /bin/bash

AWS_REGION = $(REGION)
CUR_DIR = $(PWD)

init:
	@cd terraform/ && terraform init

update:
    @cd terraform/ && terraform get -update=true 1>/dev/null

unittest:
	@python -m unittest $(CUR_DIR)/src/unittest/test.py

plan: init update
    @cd terraform/ && terraform plan \
		-input=false \
		-refresh=true \
		-module-depth=-1

apply: init update unittest
	@cd terraform/ && terraform apply \
		-input=true \
		-refresh=true \
		&& cd $(CUR_DIR)/src && rm -rf main.zip

plan-destroy: init update
    @cd terraform/ && terraform plan \
		-input=false \
		-refresh=true \
		-module-depth=-1 \
		-destroy

destroy: init update
	@cd terraform/ && terraform destroy

destroy-auto: init update
	@cd terraform/ && terraform destroy \
	    -auto-approve

clean:
	@cd terraform/ && rm -fR .terraform/modules




