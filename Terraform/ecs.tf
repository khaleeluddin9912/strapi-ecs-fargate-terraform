# ECS Cluster
resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Fargate Spot Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "khaleel_cluster_capacity" {
  cluster_name = aws_ecs_cluster.khaleel_strapi_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = data.aws_iam_role.ecs_execution.arn
  task_role_arn      = data.aws_iam_role.ecs_task.arn  # ✅ Existing role provided by admin

  container_definitions = jsonencode([{
    name      = "strapi"
    image     = var.image_uri
    essential = true
    cpu       = 512
    memory    = 1024

    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]

    environment = [
      { name = "NODE_ENV", value = "production" },
      { name = "HOST", value = "0.0.0.0" },
      { name = "PORT", value = "1337" },

      { name = "DATABASE_CLIENT", value = "postgres" },
      { name = "DATABASE_HOST", value = aws_db_instance.strapi_db.address },
      { name = "DATABASE_PORT", value = "5432" },
      { name = "DATABASE_NAME", value = "strapidb" },
      { name = "DATABASE_USERNAME", value = "strapiadmin" },
      { name = "DATABASE_PASSWORD", value = random_password.db_password.result },

      { name = "APP_KEYS", value = "${random_password.app_key1.result},${random_password.app_key2.result},${random_password.app_key3.result},${random_password.app_key4.result}" },
      { name = "API_TOKEN_SALT", value = random_password.api_salt.result },
      { name = "ADMIN_JWT_SECRET", value = random_password.admin_jwt.result },
      { name = "JWT_SECRET", value = random_password.jwt_secret.result },

      { name = "STRAPI_DISABLE_UPDATE_NOTIFICATION", value = "true" },
      { name = "STRAPI_TELEMETRY_DISABLED", value = "true" },
      { name = "BROWSER", value = "none" }
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

# ECS Service using Fargate Spot
resource "aws_ecs_service" "khaleel_strapi_service" {
  name            = "khaleel-strapi-service"
  cluster         = aws_ecs_cluster.khaleel_strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }

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

  health_check_grace_period_seconds = 300
  enable_execute_command            = true

  depends_on = [aws_lb_listener.http]
}
