output "alb_dns_name" {
  description = "ALB DNS name for Strapi"
  value       = aws_lb.strapi_alb.dns_name
}

output "strapi_url" {
  description = "Full Strapi URL"
  value       = "http://${aws_lb.strapi_alb.dns_name}"
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.strapi_db.endpoint
}