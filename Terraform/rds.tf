# DB password
resource "random_password" "db_password" {
  length  = 16
  special = false
}

# Use existing RDS subnet group
data "aws_db_subnet_group" "strapi_db" {
  name = "khaleel-strapi-db-subnet-group"
}

# RDS Security Group - FIXED VERSION
resource "aws_security_group" "rds_sg" {
  name   = "khaleel-rds-sg"
  vpc_id = data.aws_vpc.default.id

  # 🔴 REMOVED: The problematic ingress block with circular dependency
  # ingress {
  #   from_port       = 5432
  #   to_port         = 5432
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.ecs_sg.id]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ ADDED: Separate security group rule - fixes the circular dependency
resource "aws_security_group_rule" "rds_allow_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_sg.id
  security_group_id        = aws_security_group.rds_sg.id
  description              = "Allow ECS tasks to connect to RDS"
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "strapi_db" {
  identifier             = "khaleel-strapi-db"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "strapidb"
  username               = "strapiadmin"
  password               = random_password.db_password.result
  port                   = 5432
  db_subnet_group_name   = data.aws_db_subnet_group.strapi_db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
  
  # 🔴 REMOVED: depends_on block - doesn't solve the core issue
  # depends_on = [
  #   aws_security_group.ecs_sg
  # ]
}