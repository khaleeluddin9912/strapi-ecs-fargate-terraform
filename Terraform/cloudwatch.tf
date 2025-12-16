resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/khaleel-strapi"
  retention_in_days = 7
