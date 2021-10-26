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

module "toshl-lambda" {
  source          = "../modules/lambda-function"
  toshl-table     = module.toshl-dynamodb.table-name
  toshl-table-arn = module.toshl-dynamodb.table-arn

  providers = {
    aws = aws.us1
  }
}