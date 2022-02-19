variable "toshl-table" {
  description = "dynamodb table for toshl"
  type        = string
}

variable "toshl-table-arn" {
  description = "dynamodb table for toshl"
  type        = string
}

variable "ecr_image_uri" {
  description = "ECR image URI to execute inside Lambda"
  type        = string
}
