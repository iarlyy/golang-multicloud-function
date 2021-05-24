output "aws_function_name" {
  value = module.aws_lambda_function.function_name
}

output "gcp_function_name" {
  value = module.gcp_function.function_name
}

output "azure_function_name" {
  value = module.azure_function.function_name
}

output "azure_function_api_url" {
  value = "https://${module.azure_function.function_hostname}/api/${module.azure_function.function_name}"
}
