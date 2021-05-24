terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

module "aws_lambda_function" {
  source = "./modules/aws-lambda-function"
  create = lookup(var.functions["aws"], "create", false)
  name   = lookup(var.functions["aws"], "function_name", null)
}

module "gcp_function" {
  source = "./modules/gcp-function"
  create = lookup(var.functions["gcp"], "create", false)
  name   = lookup(var.functions["gcp"], "function_name", null)
  region = var.gcp_region
}

module "azure_function" {
  source = "./modules/azure-function"
  create = lookup(var.functions["azure"], "create", false)
  name   = lookup(var.functions["azure"], "function_name", null)
  region = var.azure_region
}
