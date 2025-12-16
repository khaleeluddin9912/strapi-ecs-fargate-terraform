output "ecs_cluster_name" {
  value = aws_ecs_cluster.khaleel_strapi_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.khaleel_strapi_service.name
}