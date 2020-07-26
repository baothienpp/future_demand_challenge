################################################################################
# Terraform base configs
################################################################################

provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = "= 0.12.24"
}

################################################################################
# S3 Bucket
################################################################################
resource "aws_s3_bucket" "anagram_bucket" {
  bucket = var.prefix == "" ? var.bucket_name : "${var.prefix}-${var.bucket_name}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.anagram_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.anagram_lambda.arn
    events = [
      "s3:ObjectCreated:*"]
    filter_prefix = "anagram"
    filter_suffix = ".csv"
  }

  depends_on = [
    aws_lambda_permission.allow_bucket]
}

################################################################################
# LAMBDA
################################################################################


## Role for LAMBDA
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"]

    principals {
      identifiers = [
        "lambda.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = data.aws_iam_policy_document.this.json
}

## S3 Access Policy for anagram
data "aws_iam_policy_document" "lambda_s3_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.anagram_bucket.arn,
    ]
  }
}

resource "aws_iam_policy" "s3_access" {
  name = aws_iam_role.iam_for_lambda.name
  policy = data.aws_iam_policy_document.lambda_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_acess" {
  policy_arn = aws_iam_policy.s3_access.arn
  role = aws_iam_role.iam_for_lambda.name
}

##Cloudwatch log for lambda
data "aws_iam_policy_document" "lambda_logging_policy" {
  statement {
    actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = data.aws_iam_policy_document.lambda_logging_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

## Build Lambda
resource "null_resource" "package_lambda" {
  triggers = {
    change = md5(file("${var.lambda_source_dir}/main.py"))
  }

  provisioner "local-exec" {
    working_dir = "../"
    command = "run build_lambda"
    interpreter = [
      "/bin/bash",
      "build_lambda.sh"]
  }
}

data "archive_file" "lambda_zip" {
  depends_on = [
    null_resource.package_lambda]
  type = "zip"
  source_dir = var.lambda_source_dir
  output_path = var.lambda_zip_file_location
}

## I decided to upload the zip source code to S3 since terraform gives me error when uploading zip file from local machine
resource "aws_s3_bucket_object" "file_upload" {
  bucket = aws_s3_bucket.anagram_bucket.id
  key = data.archive_file.lambda_zip.output_path
  source = data.archive_file.lambda_zip.output_path
  etag = filemd5("${var.lambda_source_dir}/main.py")
}

resource "aws_lambda_function" "anagram_lambda" {
  depends_on = [
    aws_s3_bucket_object.file_upload]
  s3_bucket = aws_s3_bucket.anagram_bucket.id
  s3_key = replace(data.archive_file.lambda_zip.output_path, "../", "")
  //  filename = data.archive_file.lambda_zip.output_path
  function_name = "anagram_lambda"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "main.handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = var.runtime
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.anagram_lambda.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.anagram_bucket.arn
}
