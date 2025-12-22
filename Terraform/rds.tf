resource "random_password" "db_password" {
  length  = 16
  special = false
}

data "aws_db_subnet_group" "strapi_db" {
  name = "khaleel-strapi-db-subnet-group"
}

resource "aws_security_group" "rds_sg" {
  name   = "khaleel-rds-sg"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "rds_allow_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}

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
}
