module "tiler" {
  source = "../../modules/task_definition"

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

resource "aws_s3_bucket" "tiles" {
  bucket = "gg.statesman.${var.env}.tiles"
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

resource "aws_cloudfront_distribution" "tiles" {
  enabled = true

  origin {
    domain_name = "${aws_s3_bucket.tiles.bucket_domain_name}"
    origin_id   = "${aws_s3_bucket.tiles.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.tiles.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "${aws_s3_bucket.tiles.id}"

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = false
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = "${aws_s3_bucket.tiles.id}"
  policy = "${data.aws_iam_policy_document.cloudfront_access.json}"
}

data "aws_iam_policy_document" "cloudfront_access" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.tiles.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.tiles.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.tiles.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.tiles.iam_arn}"]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "tiles" {}
