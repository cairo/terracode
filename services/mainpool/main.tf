module "mainpool" {
  source = "../../modules/cluster"

  name          = "mainpool"
  subnet_ids    = ["${var.subnet_ids}"]
  vpc_id        = "${var.vpc_id}"
  min_size      = "3"
  max_size      = "3"
  instance_type = "t2.medium"
}
