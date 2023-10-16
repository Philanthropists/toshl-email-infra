output "table-state-name" {
  description = "dynamodb table name for state"
  value       = aws_dynamodb_table.toshl-data.name
}

output "table-state-arn" {
  description = "dynamodb table arn for state"
  value       = aws_dynamodb_table.toshl-data.arn
}

output "table-users-name" {
  description = "dynamodb table name for users"
  value       = aws_dynamodb_table.toshl-users.name
}

output "table-users-arn" {
  description = "dynamodb table arn for users"
  value       = aws_dynamodb_table.toshl-users.arn
}
