resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow HTTP access to Strapi"
  vpc_id      = data.aws_vpc.default.id  # Use default VPC

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-sg"
  }
}

data "aws_vpc" "default" {
  default = true
}
