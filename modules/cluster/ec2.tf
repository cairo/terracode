resource "aws_autoscaling_group" "cluster" {
  name                 = "${var.name}"
  launch_configuration = "${aws_launch_configuration.cluster.name}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"

  tag {
    key                 = "Name"
    value               = "${var.name}-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "cluster" {
  name_prefix          = "${var.name}-"
  image_id             = "${data.aws_ami.ecs_optimized.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_agent.name}"
  user_data            = "${data.template_file.user_data.rendered}"
  security_groups      = ["${aws_security_group.allow_all_egress.id}"]
  instance_type        = "${var.instance_type}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_all_egress" {
  name_prefix = "${var.name}-"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name_prefix = "${var.name}-ecs-agent-"
  role        = "${aws_iam_role.ecs_agent.name}"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "ecs_optimized" {
  filter {
    name   = "name"
    values = ["amzn-ami-2017.09.l-amazon-ecs-optimized"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data")}"

  vars {
    ecs_cluster = "${var.name}"
  }
}
