output "ecr_repository" {
  value       = module.ecr-repo.repository_url
  description = "ECR Repository URL"
}
