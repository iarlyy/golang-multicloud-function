output "function_name" {
  value = element(concat(azurerm_function_app.this.*.name, [""]), 0)
}

output "function_hostname" {
  value = element(concat(azurerm_function_app.this.*.default_hostname, [""]), 0)
}
