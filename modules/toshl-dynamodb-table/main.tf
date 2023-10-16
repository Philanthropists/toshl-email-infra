resource "aws_dynamodb_table" "toshl-data" {
  name           = "toshl-data"
  billing_mode   = "PROVISIONED"
  hash_key       = "Id"
  write_capacity = 1
  read_capacity  = 1

  attribute {
    name = "Id"
    type = "N"
  }

}

resource "aws_dynamodb_table" "toshl-users" {
  name           = "toshl-users"
  billing_mode   = "PROVISIONED"
  hash_key       = "Email"
  write_capacity = 20
  read_capacity  = 20

  attribute {
    name = "Email"
    type = "S"
  }

}
