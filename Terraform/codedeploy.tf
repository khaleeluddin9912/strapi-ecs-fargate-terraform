resource "aws_codedeploy_app" "strapi_app" {
  name             = "khaleel-strapi-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "strapi_deployment_group" {
  app_name              = aws_codedeploy_app.strapi_app.name
  deployment_group_name = "khaleel-strapi-dg"
  service_role_arn      = data.aws_iam_role.ecs_execution.arn

  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  ecs_service {
    cluster_name = aws_ecs_cluster.khaleel_strapi_cluster.name
    service_name = aws_ecs_service.khaleel_strapi_service.name
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                          = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    green_fleet_provisioning_option {
      action = "DISCOVER_EXISTING"
    }
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.strapi_blue.name
      }

      target_group {
        name = aws_lb_target_group.strapi_green.name
      }

      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = [
      "DEPLOYMENT_FAILURE",
      "DEPLOYMENT_STOP_ON_ALARM",
      "DEPLOYMENT_STOP_ON_REQUEST"
    ]
  }

  depends_on = [
    aws_ecs_service.khaleel_strapi_service,
    aws_lb_listener.http
  ]
}
