output "table-name" {
  description = "dynamodb table name"
  value       = aws_dynamodb_table.toshl-data.name
}

output "table-arn" {
  description = "dynamodb table name"
  value       = aws_dynamodb_table.toshl-data.arn
}