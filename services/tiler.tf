module "tiler" {
  source = "../modules/task_definition"

  name              = "tiler"
  image_tag         = "06e71f5"
  task_role_arn     = ""
  container_port    = "80"
  host_port         = "80"
  cpu               = "256"
  memory_soft_limit = "1024"
  memory_hard_limit = "1024"
  network_mode      = "awsvpc"

  env_vars {
    AWS_ENDPOINT_URL   = "s3.us-east-1.amazonaws.com"
    OUTPUT_BUCKET_NAME = "${aws_s3_bucket.tiles.id}"
    OUTPUT_DIR         = "0.1"
  }
}

resource "aws_iam_role_policy" "tiler_write_s3" {
  name   = "tiler_write_s3"
  role   = "${module.tiler.task_role_id}"
  policy = "${data.aws_iam_policy_document.tiler_write_s3.json}"
}

data "aws_iam_policy_document" "tiler_write_s3" {
  statement {
    actions   = ["s3:ListObjects", "s3:PutObject"]
    resources = ["${aws_s3_bucket.tiles.arn}/*"]
  }
}
