resource "aws_cloudwatch_dashboard" "khaleel_dashboard" {
  dashboard_name = "khaleel-strapi-ecs-dashboard"

  dashboard_body = jsonencode({
    widgets = [

      # CPU
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name, "ServiceName", aws_ecs_service.khaleel_strapi_service.name]
          ],
          period = 60,
          stat   = "Average",
          region = "ap-south-1",
          title  = "CPU Utilization"
        }
      },

      # Memory
      {
        type = "metric",
        x = 12,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name, "ServiceName", aws_ecs_service.khaleel_strapi_service.name]
          ],
          period = 60,
          stat   = "Average",
          region = "ap-south-1",
          title  = "Memory Utilization"
        }
      },

      # ✅ TASK COUNT (FIXED)
      {
        type = "metric",
        x = 0,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "DesiredTaskCount", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name, "ServiceName", aws_ecs_service.khaleel_strapi_service.name]
          ],
          period = 60,
          stat   = "Average",
          region = "ap-south-1",
          title  = "Desired Task Count"
        }
      },

      # ✅ NETWORK (Container Insights – FIXED)
      {
        type = "metric",
        x = 12,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "NetworkRxBytes", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name],
            ["ECS/ContainerInsights", "NetworkTxBytes", "ClusterName", aws_ecs_cluster.khaleel_strapi_cluster.name]
          ],
          period = 60,
          stat   = "Sum",
          region = "ap-south-1",
          title  = "Network In / Out"
        }
      }
    ]
  })

  depends_on = [aws_ecs_service.khaleel_strapi_service]
}
