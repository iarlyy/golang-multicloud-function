variable "create" {
  type    = bool
  default = false
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "dist_file" {
  type    = string
  default = "../build/azure_function.zip"
}
