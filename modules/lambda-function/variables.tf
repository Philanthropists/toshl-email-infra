variable "toshl-table-arns" {
  description = "dynamodb tables for toshl"
  type        = list(string)
}

variable "ecr_image_uri" {
  description = "ECR image URI to execute inside Lambda"
  type        = string
}
