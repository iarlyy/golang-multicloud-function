output "function_name" {
  value = element(concat(aws_lambda_function.this.*.function_name, [""]), 0)
}
