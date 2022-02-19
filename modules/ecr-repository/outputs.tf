output "ecr_arn" {
  value       = aws_ecr_repository.repository.arn
  description = "ECR ARN"
}

output "registry_id" {
  value       = aws_ecr_repository.repository.registry_id
  description = "ECR Registry ID"
}

output "repository_url" {
  value       = aws_ecr_repository.repository.repository_url
  description = "ECR Repository URL"
}
