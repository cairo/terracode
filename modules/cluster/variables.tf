variable "name" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "min_size" {
  type = "string"
}

variable "max_size" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}
