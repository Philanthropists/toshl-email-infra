locals {
  common_tags = {
    "Product" = "toshl-email-sync"
  }
}

provider "aws" {
  alias  = "us1"
  region = "us-east-1"
  default_tags {
    tags = local.common_tags
  }
}

module "toshl-dynamodb" {
  source = "../modules/toshl-dynamodb-table"

  providers = {
    aws = aws.us1
  }
}

module "ecr-repo" {
  source = "../modules/ecr-repository"

  providers = {
    aws = aws.us1
  }
}

module "toshl-lambda" {
  source = "../modules/lambda-function"
  toshl-table-arns = [
    module.toshl-dynamodb.table-state-arn,
    module.toshl-dynamodb.table-users-arn,
  ]
  ecr_image_uri = "${module.ecr-repo.repository_url}:latest"

  providers = {
    aws = aws.us1
  }
}
