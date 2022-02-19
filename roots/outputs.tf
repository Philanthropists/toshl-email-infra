output "lambda_function_archive_hash" {
  value       = module.toshl-lambda.archive_hash
  description = "lamdba function archive hash value"
}

output "ecr_repository" {
  value       = module.ecr-repo.repository_url
  description = "ECR Repository URL"
}
