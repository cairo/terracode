variable "name" {
  type = "string"
}

variable "image_tag" {
  type = "string"
}

variable "task_role_arn" {
  type = "string"
}

variable "container_port" {
  type = "string"
}

variable "host_port" {
  type = "string"
}

variable "cpu" {
  type = "string"
}

variable "memory_hard_limit" {
  type = "string"
}

variable "memory_soft_limit" {
  type = "string"
}

variable "env_vars" {
  type    = "map"
  default = {}
}
