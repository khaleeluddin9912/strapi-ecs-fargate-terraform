resource "aws_security_group" "strapi_sg" {
  name        = "khaleel-strapi-sg"
  description = "Allow HTTP via ALB and Strapi app traffic"
  vpc_id      = data.aws_vpc.default.id

  # ALB HTTP access (public)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Strapi application port (ALB → ECS)
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "khaleel-strapi-sg"
  }
}
