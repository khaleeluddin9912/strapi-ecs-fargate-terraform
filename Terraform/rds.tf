# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "khaleel-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  # Allow PostgreSQL from ECS
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "strapi_db" {
  name       = "khaleel-strapi-db-subnet"
  subnet_ids = data.aws_subnets.default.ids
}

# Database Password
resource "random_password" "db_password" {
  length = 16
}

# Store password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "khaleel-strapi-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# RDS PostgreSQL Database
resource "aws_db_instance" "strapi_db" {
  identifier     = "khaleel-strapi-db"
  engine        = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  allocated_storage = 20

  db_name  = "strapidb"
  username = "strapiadmin"
  password = random_password.db_password.result
  port     = 5432

  db_subnet_group_name = aws_db_subnet_group.strapi_db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible = true

  skip_final_snapshot = true
}