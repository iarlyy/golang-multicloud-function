base_dir := $(shell pwd)
terraform_values_path := $(shell echo $(base_dir)/terraform.tfvars)
build_folder_path := "./build"
dist_package_filename := "function.zip"
gcp_project_name := ""
gcp_region := ""

invoke-aws:
	aws lambda invoke \
		--function-name $(shell cd terraform ; terraform output -raw aws_function_name) \
		--payload $(shell cat events/aws_lambda.json| base64 ) out \
		--log-type Tail \
		--query 'LogResult' --output text |  base64 -d && \
		cat out | jq -r && rm -f out

invoke-gcp:
	gcloud functions call \
		$(shell cd terraform ; terraform output -raw gcp_function_name|cut -d "/" -f6) \
		--data '$(shell cat events/gcp_function.json)'	 \
		--project $(gcp_project_name) \
		--region $(gcp_region)

invoke-azure:
	curl -v --data '$(shell cat events/azure_function.json)' \
		$(shell cd terraform ; terraform output -raw azure_function_api_url)

invoke-all: invoke-aws invoke-gcp invoke-azure

.PHONY: build-aws
build-aws:
	@echo building aws && \
	mkdir -p $(build_folder_path)/aws && \
	GOOS=linux go build -o $(build_folder_path)/aws/main aws_handler.go && \
	cd $(build_folder_path)/aws/ && \
	zip -r9 ../aws_function.zip * && \
	cd .. && rm -rf aws

.PHONY: build-azure
build-azure:
	@echo building azure && \
	mkdir -p $(build_folder_path)/az/golangmulticloud && \
	GOOS=linux go build -o $(build_folder_path)/az/azure_handler azure_handler.go && \
	cp host.json $(build_folder_path)/az/ && \
	cp function.json $(build_folder_path)/az/golangmulticloud/ && \
	cd $(build_folder_path)/az/ && \
	zip -r9 ../azure_function.zip * && \
	cd .. && rm -rf az

.PHONY: build-gcp
build-gcp:
	@echo building gcp && \
	mkdir -p $(build_folder_path)/gcp && \
	cp -r go.* gcp_handler.go function $(build_folder_path)/gcp/ && \
	cd $(build_folder_path)/gcp/ && \
	zip -r9 ../gcp_function.zip * && \
	cd .. && rm -rf gcp


.PHONY: build-prep
build-prep:
	@echo prep && \
	if [ -d $(build_folder_path) ]; then rm -rf $(build_folder_path); fi

.PHONY: build
build: build-prep build-aws build-azure build-gcp

deploy-multicloud:
	@cd terraform && \
	terraform init && \
	terraform apply -var-file=$(terraform_values_path)

destroy-multicloud:
	@cd terraform && \
	terraform init && \
	terraform destroy -var-file=$(terraform_values_path)
