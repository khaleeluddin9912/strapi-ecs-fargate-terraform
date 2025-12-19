# ECS Cluster
resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ✅ ADD THIS: Fargate Spot Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "khaleel_cluster_capacity" {
  cluster_name = aws_ecs_cluster.khaleel_strapi_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }
}

# ECS Task Definition - UPDATED for PostgreSQL RDS
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = data.aws_iam_role.ecs_execution.arn

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
      { name = "NODE_ENV", value = "production" },  # ✅ Changed from development
      { name = "HOST", value = "0.0.0.0" },
      { name = "PORT", value = "1337" },
      
      # ✅ CHANGED: PostgreSQL RDS Configuration (Replaced SQLite)
      { name = "DATABASE_CLIENT", value = "postgres" },
      { name = "DATABASE_HOST", value = aws_db_instance.strapi_db.address },
      { name = "DATABASE_PORT", value = "5432" },
      { name = "DATABASE_NAME", value = "strapidb" },
      { name = "DATABASE_USERNAME", value = "strapiadmin" },
      { name = "DATABASE_SSL", value = "false" },
      
      # Strapi optimization variables
      { name = "STRAPI_DISABLE_UPDATE_NOTIFICATION", value = "true" },
      { name = "STRAPI_TELEMETRY_DISABLED", value = "true" },
      { name = "BROWSER", value = "none" }
    ]

    # ✅ ADDED: Secrets from Secrets Manager (Secure)
    secrets = [
      {
        name      = "DATABASE_PASSWORD"
        valueFrom = aws_secretsmanager_secret.db_password.arn
      },
      {
        name      = "APP_KEYS"
        valueFrom = "${aws_secretsmanager_secret.strapi_app.arn}:APP_KEYS::"
      },
      {
        name      = "API_TOKEN_SALT"
        valueFrom = "${aws_secretsmanager_secret.strapi_app.arn}:API_TOKEN_SALT::"
      },
      {
        name      = "ADMIN_JWT_SECRET"
        valueFrom = "${aws_secretsmanager_secret.strapi_app.arn}:ADMIN_JWT_SECRET::"
      },
      {
        name      = "JWT_SECRET"
        valueFrom = "${aws_secretsmanager_secret.strapi_app.arn}:JWT_SECRET::"
      }
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

# ✅ ADD THIS: CloudWatch Log Group
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/khaleel-strapi"
  retention_in_days = 7
}

# ECS Service - UPDATED for Fargate Spot
resource "aws_ecs_service" "khaleel_strapi_service" {
  name            = "khaleel-strapi-service"
  cluster         = aws_ecs_cluster.khaleel_strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  
  # ✅ CHANGED: Use Fargate Spot instead of regular Fargate
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }

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

  # ✅ INCREASED: Give 5 minutes for Fargate Spot to start
  health_check_grace_period_seconds = 300

  # ✅ ADDED: Enable execute command for debugging
  enable_execute_command = true

  depends_on = [aws_lb_listener.http]
}