terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
  }
}

resource "aws_dynamodb_table" "toshl-data" {
  name           = "toshl-data"
  billing_mode   = "PROVISIONED"
  hash_key       = "Id"
  write_capacity = 20
  read_capacity  = 20

  attribute {
    name = "Id"
    type = "N"
  }

}