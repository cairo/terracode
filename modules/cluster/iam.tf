resource "aws_iam_role" "ecs_agent" {
  name_prefix        = "${var.name}-ecs-agent-"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_agent.json}"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = "${aws_iam_role.ecs_agent.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
