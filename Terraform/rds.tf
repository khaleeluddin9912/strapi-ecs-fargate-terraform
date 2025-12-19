# Database Password
resource "random_password" "db_password" {
  length = 16
}

# ✅ REMOVE THESE LINES (35-42):
# Store password in Secrets Manager
# resource "aws_secretsmanager_secret" "db_password" {
#   name = "khaleel-strapi-db-password"
# }
# 
# resource "aws_secretsmanager_secret_version" "db_password_version" {
#   secret_id = aws_secretsmanager_secret.db_password.id
#   secret_string = random_password.db_password.result
# }

# RDS PostgreSQL Database
resource "aws_db_instance" "strapi_db" {
  identifier     = "khaleel-strapi-db"
  engine        = "postgres"
  engine_version = "15.2"  # ✅ CHANGED
  instance_class = "db.t3.micro"
  allocated_storage = 20

  db_name  = "strapidb"
  username = "strapiadmin"
  password = random_password.db_password.result  # ✅ Use directly
  port     = 5432

  db_subnet_group_name = aws_db_subnet_group.strapi_db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible = true

  skip_final_snapshot = true
}