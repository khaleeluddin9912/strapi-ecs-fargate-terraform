# Generate DB password
resource "random_password" "db_password" {
  length = 16
}

# RDS Subnet Group (REQUIRED – fixes undeclared resource error)
resource "aws_db_subnet_group" "strapi_db" {
  name       = "khaleel-strapi-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

# RDS Security Group (REQUIRED – fixes undeclared resource error)
resource "aws_security_group" "rds_sg" {
  name   = "khaleel-rds-sg"
  vpc_id = data.aws_vpc.default.id

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

# RDS PostgreSQL Instance
resource "aws_db_instance" "strapi_db" {
  identifier        = "khaleel-strapi-db"
  engine            = "postgres"
  engine_version    = "14.11"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "strapidb"
  username = "strapiadmin"
  password = random_password.db_password.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.strapi_db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true

  skip_final_snapshot = true
}
