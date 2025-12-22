# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets (one per AZ)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# IAM execution role
data "aws_iam_role" "ecs_execution" {
  name = "khaleel-ecs-execution-role"
}
