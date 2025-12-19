# RDS PostgreSQL Database
resource "aws_db_instance" "strapi_db" {
  identifier          = "khaleel-strapi-db"
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp3"
  storage_encrypted   = true
  
  db_name            = "strapidb"
  username           = "strapiadmin"
  password           = random_password.db_password.result
  port               = 5432

  db_subnet_group_name   = aws_db_subnet_group.strapi_db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true
  
  multi_az               = false
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  max_allocated_storage = 100
  
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  skip_final_snapshot = true
  deletion_protection = false
  
  # Monitoring (optional - remove if you don't have the role)
  # monitoring_interval = 60
  # monitoring_role_arn = data.aws_iam_role.rds_monitoring.arn
  
  tags = {
    Name = "khaleel-strapi-database"
    Environment = "development"
  }
}