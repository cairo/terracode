module "services" {
  source = "./services"

  env = "${var.env}"
}

variable "env" {
  type = "string"
}
