module "tiler" {
  source = "../modules/task_definition"

  name              = "tiler"
  image_tag         = "cbcf18b"
  task_role_arn     = ""
  container_port    = "80"
  host_port         = "80"
  cpu               = "2048"
  memory_soft_limit = "3072"
  memory_hard_limit = "3072"

  env_vars {
    AWS_ENDPOINT_URL   = "https://s3.us-east-1.amazonaws.com"
    OUTPUT_BUCKET_NAME = "${aws_s3_bucket.tiles.id}"
    OUTPUT_DIR         = "0.1.0"
  }
}

resource "aws_iam_role_policy" "tiler_read_write_s3" {
  role   = "${module.tiler.task_role_id}"
  policy = "${data.aws_iam_policy_document.tiler_read_write_s3.json}"
}

data "aws_iam_policy_document" "tiler_read_write_s3" {
  statement {
    actions   = ["s3:ListObjects", "s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.tiles.arn}/*"]
  }
}
