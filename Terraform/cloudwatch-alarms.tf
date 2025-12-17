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
resource "aws_cloudwatch_metric_alarm" "khaleel_ecs_task_count_low" {
  alarm_name          = "khaleel-ecs-task-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    ClusterName = aws_ecs_cluster.khaleel_strapi_cluster.name
    ServiceName = aws_ecs_service.khaleel_strapi_service.name
  }

  alarm_description = "Task count is low for Khaleel Strapi ECS service"
  depends_on        = [aws_ecs_service.khaleel_strapi_service]
}
