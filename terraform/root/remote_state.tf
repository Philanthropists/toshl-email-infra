terraform {
  backend "s3" {
    key            = "terraform/dev.tfstate"
    bucket         = "personal-aanzolaavila-terraform-state"
    dynamodb_table = "personal-aanzolaavila-terraform-state-locks"

    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

locals {
    bucket_prefix = "personal-aanzolaavila-terraform-state"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.bucket_prefix

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${local.bucket_prefix}-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
