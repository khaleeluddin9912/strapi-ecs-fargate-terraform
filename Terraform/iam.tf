# Reference existing IAM role instead of creating a new one
data "aws_iam_role" "ecs_execution" {
  name = "ecs-execution-role"
}

# You can skip attaching policy if it's already attached
# resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
#   role       = data.aws_iam_role.ecs_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
