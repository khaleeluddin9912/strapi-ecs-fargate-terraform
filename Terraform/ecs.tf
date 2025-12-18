# ECS Cluster
resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = data.aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name      = "strapi"
    image     = var.image_uri
    essential = true

    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]

    environment = [
      { name = "NODE_ENV", value = "production" },
      { name = "HOST", value = "0.0.0.0" },
      { name = "PORT", value = "1337" },
      { name = "APP_KEYS", value = "key1,key2,key3,key4" },
      { name = "API_TOKEN_SALT", value = "randomsalt123" },
      { name = "ADMIN_JWT_SECRET", value = "adminjwtsecret123" },
      { name = "JWT_SECRET", value = "jwtsecret123" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.strapi.name
        awslogs-region        = "ap-south-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# ECS Service
resource "aws_ecs_service" "khaleel_strapi_service" {
  name            = "khaleel-strapi-service"
  cluster         = aws_ecs_cluster.khaleel_strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # CONNECT TO ALB
  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_lb_listener.http]
}