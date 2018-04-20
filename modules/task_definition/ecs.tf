resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.name}"
  container_definitions = "${data.template_file.container_definitions.rendered}"
  task_role_arn         = "${aws_iam_role.task_role.arn}"
  execution_role_arn    = "${aws_iam_role.task_role.arn}"
  network_mode          = "${var.network_mode}"
  cpu                   = "${var.cpu}"
  memory                = "${var.memory_soft_limit}"
}

data "template_file" "container_definitions" {
  template = "${file("${path.module}/container_definition.json")}"

  vars {
    name              = "${var.name}"
    image             = "${data.aws_ecr_repository.image_repo.repository_url}:${var.image_tag}"
    task_role_arn     = "${aws_iam_role.task_role.arn}"
    container_port    = "${var.container_port}"
    host_port         = "${var.host_port}"
    cpu               = "${var.cpu}"
    memory_hard_limit = "${var.memory_hard_limit}"
    memory_soft_limit = "${var.memory_soft_limit}"
    network_mode      = "${var.network_mode}"
    env_vars          = "${format("[%s]", join(",", formatlist("{ \"name\": \"%s\", \"value\": \"%s\" }", keys(var.env_vars), values(var.env_vars))))}"
  }
}

data "aws_ecr_repository" "image_repo" {
  name = "${var.name}"
}
