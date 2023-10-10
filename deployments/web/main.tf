terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.14"
  backend "s3" {
    region = "us-east-1"
  }
}

# Main region where the resources should be created in
# Should be close to the location of your viewers
provider "aws" {
  region = "us-east-1"
}

# Provider used for creating the Lambda@Edge function which must be deployed
# to us-east-1 region (Should not be changed)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

###########
# Locals
###########

locals {
  lambda_array = {   
    "default" = {
      name = "default",
      source_dir = "${var.lambda_dir}/server-function"
    }
    "image" = {
      name = "image",
      source_dir = "${var.lambda_dir}/image-optimization-function"
    }
  }
}

########
# S3 bucket
########
# Note: The bucket name needs to carry the same name as the domain!
# http://stackoverflow.com/a/5048129/2966951
resource "aws_s3_bucket" "br-nodereport-bucket" {
  bucket = "${var.service_name}-${var.env}"
}

resource "aws_s3_bucket_public_access_block" "br-nodereport-bucket_acl" {
  bucket = aws_s3_bucket.br-nodereport-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "my-oai" {
  comment = "${var.service_name}-${var.env}"
}

resource "aws_s3_bucket_policy" "cdn-cf-policy" {
  bucket = aws_s3_bucket.br-nodereport-bucket.id
  policy = data.aws_iam_policy_document.my-cdn-cf-policy.json
}

data "aws_iam_policy_document" "my-cdn-cf-policy" {
  statement {
    sid = "1"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.my-oai.iam_arn]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.br-nodereport-bucket.arn}/*"
    ]
  }
}

module "cloudfront_s3" {
  source                           = "git@github.com:mamistry/tf-open-next-terraform.git"
  providers = {
    aws = aws.us_east_1
  }
  environment                      = var.env
  s3_bucket_regional_domain_name   = aws_s3_bucket.br-nodereport-bucket.bucket_regional_domain_name
  s3_bucket_arn                    = aws_s3_bucket.br-nodereport-bucket.arn
  s3_bucket_id                     = aws_s3_bucket.br-nodereport-bucket.id
  custom_domain                    = var.custom_domain
  custom_domain_zone_name          = var.custom_domain_zone_name
  lambda_array                     = local.lambda_array
  certificate_arn                  = var.cloudfront_cert
  cloudfront_access_identity_path  = aws_cloudfront_origin_access_identity.my-oai.cloudfront_access_identity_path
  service_name                     = var.service_name 
}
