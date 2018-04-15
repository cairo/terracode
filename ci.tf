resource "aws_iam_user" "ci" {
  name = "ci"
}

resource "aws_iam_user_policy_attachment" "ci" {
  user       = "${aws_iam_user.ci.name}"
  policy_arn = "${data.aws_iam_policy.ecr_power_user.arn}"
}

data "aws_iam_policy" "ecr_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
