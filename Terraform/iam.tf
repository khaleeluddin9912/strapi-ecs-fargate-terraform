# Use existing ECS execution role (must already exist in AWS account)
data "aws_iam_role" "ecs_execution" {
  name = "khaleel-ecs-execution-role"
}
