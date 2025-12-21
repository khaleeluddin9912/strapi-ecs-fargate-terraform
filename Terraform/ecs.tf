#################################
# ECS CLUSTER
#################################
resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#################################
# CAPACITY PROVIDERS (FARGATE SPOT)
#################################
resource "aws_ecs_cluster_capacity_providers" "khaleel_cluster_capacity" {
  cluster_name       = aws_ecs_cluster.khaleel_strapi_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }
}

#################################
# ECS TASK DEFINITION
#################################
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  # ⚠️ USING EXISTING ROLE ONLY (NO CREATION)
  execution_role_arn = data.aws_iam_role.ecs_execution.arn
  task_role_arn      = data.aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.image_uri
      essential = true

      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]

      # ✅ ADDED: Health check to ensure Strapi is fully started before marking as healthy
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:1337/ || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 90  # Give Strapi extra time to connect to database
      }

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

        # ✅ CRITICAL: Add SSL connection parameters
        { name = "DATABASE_SSL", value = "true" },
        { name = "DATABASE_SSL_REJECT_UNAUTHORIZED", value = "false" },

        { name = "APP_KEYS", value = "${random_password.app_key1.result},${random_password.app_key2.result},${random_password.app_key3.result},${random_password.app_key4.result}" },
        { name = "API_TOKEN_SALT", value = random_password.api_salt.result },
        { name = "ADMIN_JWT_SECRET", value = random_password.admin_jwt.result },
        { name = "JWT_SECRET", value = random_password.jwt_secret.result }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.strapi.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

#################################
# ECS SERVICE (FARGATE SPOT)
#################################
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

  depends_on = [
    aws_lb_listener.http
  ]
}