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