resource "aws_s3_bucket" "tiles" {
  bucket = "gg.statesman.${var.env}.tiles"
}
