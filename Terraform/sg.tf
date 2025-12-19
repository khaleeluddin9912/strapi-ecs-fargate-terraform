# ALB Security Group - ✅ CORRECT
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

# ECS Security Group - ✅ UPDATED for RDS Access
resource "aws_security_group" "ecs_sg" {
  name   = "khaleel-ecs-sg"
  vpc_id = data.aws_vpc.default.id

  # ✅ CORRECT: Allow from ALB
  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # ❌ MISSING: Add egress rule for RDS PostgreSQL (port 5432)
  egress {
    description = "Allow ECS to connect to RDS PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ✅ KEEP: General outbound (for ECR, Secrets Manager, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}