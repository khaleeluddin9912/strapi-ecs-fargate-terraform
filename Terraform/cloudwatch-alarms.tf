# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "khaleel_ecs_cpu_high" {
  alarm_name          = "khaleel-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    ClusterName = aws_ecs_cluster.khaleel_strapi_cluster.name
    ServiceName = aws_ecs_service.khaleel_strapi_service.name
  }

  alarm_description = "High CPU usage on Khaleel Strapi ECS service"
  depends_on        = [aws_ecs_service.khaleel_strapi_service]
}

# Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "khaleel_ecs_memory_high" {
  alarm_name          = "khaleel-ecs-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75

  dimensions = {
    ClusterName = aws_ecs_cluster.khaleel_strapi_cluster.name
    ServiceName = aws_ecs_service.khaleel_strapi_service.name
  }

  alarm_description = "High Memory usage on Khaleel Strapi ECS service"
  depends_on        = [aws_ecs_service.khaleel_strapi_service]
}

# Optional: Task Count Low Alarm
resource "aws_cloudwatch_metric_alarm" "khaleel_ecs_task_desired" {
  alarm_name          = "khaleel-ecs-desired-task-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DesiredTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    ClusterName = aws_ecs_cluster.khaleel_strapi_cluster.name
    ServiceName = aws_ecs_service.khaleel_strapi_service.name
  }

  alarm_description = "Desired task count dropped below 1"
}
