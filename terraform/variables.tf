variable "aws_region" {
  default = "eu-west-1"
}

variable "bucket_name" {
  default = "anagram-fd-testing"
}

variable "runtime"{
  default = "python3.7"
}

variable "lambda_source_dir" {
  default = "../src/anagram"
}

variable "lambda_zip_file_location" {
  default = "../src/main.zip"
}