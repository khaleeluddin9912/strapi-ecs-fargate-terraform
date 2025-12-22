#################################
# ECS Execution Role
#################################
data "aws_iam_role" "ecs_execution" {
  name = "khaleel-ecs-execution-role"
}

#################################
# CodeDeploy Service Role
#################################
# CodeDeploy Service Role
resource "aws_iam_role" "codedeploy_role" {
  name = "khaleel-codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
