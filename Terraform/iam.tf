#################################
# ECS Execution Role
#################################
data "aws_iam_role" "ecs_execution" {
  name = "khaleel-ecs-execution-role"
}

#################################
# CodeDeploy Service Role
#################################
data "aws_iam_role" "codedeploy_role" {
  name = "khaleel-codedeploy-role"
}
