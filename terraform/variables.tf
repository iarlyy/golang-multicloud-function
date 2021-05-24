variable "aws_region" {
  type = string
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "azure_region" {
  type = string
}

variable "azure_subscription_id" {
  type = string
}

variable "functions" {
  type    = map(any)
  default = {}
}
