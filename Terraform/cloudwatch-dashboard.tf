resource "aws_cloudwatch_dashboard" "khaleel_dashboard" {
  dashboard_name = "khaleel-strapi-ecs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name, "ServiceName", aws_ecs_service.khaleel_strapi_service.name]
          ]
          period      = 60
          stat        = "Average"
          region      = "ap-south-1"
          title       = "CPU Utilization"
          view        = "timeSeries"
          stacked     = false
          annotations = {}
        }
      },
      {
        type = "metric",
        x = 12,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name, "ServiceName", aws_ecs_service.khaleel_strapi_service.name]
          ]
          period      = 60
          stat        = "Average"
          region      = "ap-south-1"
          title       = "Memory Utilization"
          view        = "timeSeries"
          stacked     = false
          annotations = {}
        }
      },
      {
        type = "metric",
        x = 0,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name, "ServiceName", aws_ecs_service.khaleel_strapi_service.name]
          ]
          period      = 60
          stat        = "Minimum"
          region      = "ap-south-1"
          title       = "Running Task Count"
          view        = "timeSeries"
          stacked     = false
          annotations = {}
        }
      },
      {
        type = "metric",
        x = 12,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "NetworkRxBytes", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name, "ServiceName", aws_ecs_service.khaleel_strapi_service.name],
            ["AWS/ECS", "NetworkTxBytes", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name, "ServiceName", aws_ecs_service.khaleel_strapi_service.name]
          ]
          period      = 60
          stat        = "Sum"
          region      = "ap-south-1"
          title       = "Network In / Out"
          view        = "timeSeries"
          stacked     = false
          annotations = {}
        }
      }
    ]
  })

  depends_on = [
    aws_ecs_service.khaleel_strapi_service
  ]
}