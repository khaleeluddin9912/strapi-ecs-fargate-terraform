#################################
# Data reference for existing ECS execution role
#################################
data "aws_iam_role" "ecs_execution" {
  name = "khaleel-ecs-execution-role"
}

#################################
# Create a new IAM role for CodeDeploy
#################################
resource "aws_iam_role" "codedeploy_role" {
  name = "khaleel-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#################################
# Attach managed policies to CodeDeploy role
#################################
resource "aws_iam_role_policy_attachment" "codedeploy_managed_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForECS"
}
