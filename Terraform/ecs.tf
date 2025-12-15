# ECS Cluster
resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"
}

# ECS Task Definition (Fargate Free-Tier Safe)
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  # Use the existing IAM role
  execution_role_arn = data.aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name  = "strapi"
    image = var.image_uri
    portMappings = [{
      containerPort = 1337
      protocol      = "tcp"
    }]
  }])
}

# ECS Service
resource "aws_ecs_service" "khaleel_strapi_service" {
  name            = "khaleel-strapi-service"
  cluster         = aws_ecs_cluster.khaleel_strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_ecs_task_definition.strapi_task
  ]
}
