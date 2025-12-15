variable "image_uri" {
  description = "Full ECR image URI with tag"
  type        = string
}

variable "subnets" {
  description = "List of subnets for ECS service"
  type        = list(string)
}

variable "sg_id" {
  description = "Security group ID for ECS service"
  type        = string
}
