output "function_name" {
  value = element(concat(google_cloudfunctions_function.this.*.id, [""]), 0)
}
