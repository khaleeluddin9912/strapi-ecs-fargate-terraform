resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "khaleel_cluster_capacity" {
  cluster_name       = aws_ecs_cluster.khaleel_strapi_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 0
  }
}

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.ecs_execution.arn
  task_role_arn            = data.aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.image_uri
      essential = true

      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost:1337/ || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 90
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
        { name = "DATABASE_SSL", value = "true" },
        { name = "DATABASE_SSL_REJECT_UNAUTHORIZED", value = "false" },

        { name = "APP_KEYS", value = local.strapi_secrets.APP_KEYS },
        { name = "API_TOKEN_SALT", value = local.strapi_secrets.API_TOKEN_SALT },
        { name = "ADMIN_JWT_SECRET", value = local.strapi_secrets.ADMIN_JWT_SECRET },
        { name = "JWT_SECRET", value = local.strapi_secrets.JWT_SECRET }
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

resource "aws_ecs_service" "khaleel_strapi_service" {
  name            = "khaleel-strapi-service"
  cluster         = aws_ecs_cluster.khaleel_strapi_cluster.id

  # ✅ REQUIRED even for CodeDeploy
  task_definition = aws_ecs_task_definition.strapi_task.arn

  desired_count = 1
  launch_type   = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  enable_ecs_managed_tags = true
  enable_execute_command  = true

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_blue.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  depends_on = [
    aws_ecs_cluster_capacity_providers.khaleel_cluster_capacity,
    aws_lb_listener.http,
    aws_lb_target_group.strapi_blue,
    aws_lb_target_group.strapi_green
  ]
}
