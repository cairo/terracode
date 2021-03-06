resource "aws_iam_role" "task_role" {
  name               = "${var.name}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role.json}"
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
