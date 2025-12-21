# ALB SG
resource "aws_security_group" "alb_sg" {
  name   = "khaleel-alb-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS SG - CORRECT VERSION
resource "aws_security_group" "ecs_sg" {
  name   = "khaleel-ecs-sg"
  vpc_id = data.aws_vpc.default.id

  # Inbound from ALB
  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # ✅ CRITICAL: KEEP THIS EGRESS RULE
  # ECS needs this to reach ECR and download Docker images
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ OPTIONAL: You can also add the specific RDS rule
resource "aws_security_group_rule" "ecs_to_rds" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_sg.id
  security_group_id        = aws_security_group.ecs_sg.id
  description              = "Allow ECS to connect to RDS PostgreSQL"
}