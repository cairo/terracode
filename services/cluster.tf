resource "aws_ecs_cluster" "cluster" {
  name = "megapool"
}

resource "aws_autoscaling_group" "cluster" {
  name                 = "megapool"
  launch_configuration = "${aws_launch_configuration.cluster.name}"
  vpc_zone_identifier  = ["${module.vpc.private_subnets}"]

  max_size = 5
  min_size = 5
}

resource "aws_launch_configuration" "cluster" {
  name                 = "megapool"
  instance_type        = "t2.micro"
  image_id             = "ami-cb2305a1"
  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"
  security_groups      = ["${aws_security_group.inbound_allow_all.id}"]

  user_data = <<EOF
#cloud-config
bootcmd:
 - cloud-init-per instance $(echo "ECS_CLUSTER=ecs-staging" >> /etc/ecs/ecs.config)
EOF
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs"
  role = "${aws_iam_role.ecs.name}"
}

resource "aws_iam_role" "ecs" {
  name = "ecs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs" {
  name       = "ecs-for-ec2"
  roles      = ["${aws_iam_role.ecs.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_security_group" "inbound_allow_all" {
  name   = "megapool-inbound-allow-all"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "megapool"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

/* resource "aws_launch_configuration" "" { */
/*   name                 = "ecs_cluster_conf" */
/*   instance_type        = "t2.micro" */
/*   image_id             = "ami-cb2305a1" */
/*   iam_instance_profile = "${aws_iam_instance_profile.ecs.id}" */


/*   security_groups = [ */
/*     "${aws_security_group.allow_all_ssh.id}", */
/*     "${aws_security_group.allow_all_outbound.id}", */
/*     "${aws_security_group.allow_cluster.id}", */
/*   ] */


/*   user_data = <<EOF */
/* #cloud-config */
/* bootcmd: */
/*  - cloud-init-per instance $(echo "ECS_CLUSTER=ecs-staging" >> /etc/ecs/ecs.config) */
/* EOF */
/* } */

