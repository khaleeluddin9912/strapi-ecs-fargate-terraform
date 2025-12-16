# Use existing CloudWatch Log Group (DO NOT CREATE)
data "aws_cloudwatch_log_group" "strapi" {
  name = "/ecs/strapi-khaleel"
}
