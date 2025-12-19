# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "khaleel-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  # Allow PostgreSQL from ECS - ✅ CORRECT
  ingress {
    description     = "Allow PostgreSQL from ECS tasks"
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

# RDS Subnet Group - ✅ CORRECT
resource "aws_db_subnet_group" "strapi_db" {
  name       = "khaleel-strapi-db-subnet"
  subnet_ids = data.aws_subnets.default.ids
  
  tags = {
    Name = "khaleel-strapi-db-subnet-group"
  }
}

# RDS PostgreSQL Database - ✅ UPDATED
resource "aws_db_instance" "strapi_db" {
  identifier          = "khaleel-strapi-db"
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp3"  # ✅ ADDED: Better storage type
  storage_encrypted   = true   # ✅ ADDED: Encrypt storage
  
  db_name            = "strapidb"
  username           = "strapiadmin"
  password           = random_password.db_password.result
  port               = 5432

  db_subnet_group_name   = aws_db_subnet_group.strapi_db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true  # ⚠️ WARNING: Set to false in production
  
  # ✅ ADDED: Performance & Availability
  multi_az               = false  # Enable for production HA
  backup_retention_period = 7     # Days of backups
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # ✅ ADDED: Auto-scaling
  max_allocated_storage = 100  # Auto-scale up to 100GB
  
  # ✅ ADDED: Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  # ⚠️ WARNING: For testing only - change for production
  skip_final_snapshot = true  # ❌ DANGEROUS: Allows DB deletion
  deletion_protection = false # ⚠️ Enable for production
  
  # ✅ ADDED: Monitoring
  monitoring_interval = 60  # Enhanced monitoring
  monitoring_role_arn = data.aws_iam_role.rds_monitoring.arn  # If you have monitoring role
  
  tags = {
    Name = "khaleel-strapi-database"
    Environment = "development"
  }
}

# Database Password - ✅ CORRECT
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store password in Secrets Manager - ✅ UPDATED
resource "aws_secretsmanager_secret" "db_password" {
  name = "khaleel-strapi-db-password"
  
  tags = {
    Name = "strapi-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# ✅ ADD: Output the full connection string
output "database_connection_string" {
  value       = "postgresql://${aws_db_instance.strapi_db.username}:${random_password.db_password.result}@${aws_db_instance.strapi_db.endpoint}/${aws_db_instance.strapi_db.db_name}"
  sensitive   = true
  description = "PostgreSQL connection string (SENSITIVE)"
}