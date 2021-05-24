# golang-multicloud-function
a golang function that is fully compatible to run on AWS Lambda, GCP Functions and Azure Functions

# Steps

#### build
> make build

#### create terraform.tfvars (edit relevant variables, such as: cloud regions, azure subscription id, gcp project id)
> cp terraform.tfvars.dist terraform.tfvars

#### deploy everything
> make deploy-multicloud

#### invoke
> make invoke-all

#### undeploy everything
> make destroy-multicloud
