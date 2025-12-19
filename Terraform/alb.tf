resource "aws_lb" "strapi_alb" {
  name               = "khaleel-strapi-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false

  tags = {
    Name = "khaleel-strapi-alb"
  }
}

resource "aws_lb_target_group" "strapi_tg" {
  name        = "khaleel-strapi-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  # CRITICAL FIX: Health check for Strapi
  health_check {
    enabled             = true
    path                = "/admin"          # CHANGE: Use /admin instead of /
    port                = "1337"
    protocol            = "HTTP"
    matcher             = "200,302,301"     # CHANGE: Accept redirects
    interval            = 60                # CHANGE: Increase to 60s
    timeout             = 20                # CHANGE: Increase to 20s
    healthy_threshold   = 2
    unhealthy_threshold = 5                 # CHANGE: Increase to 5
  }

  tags = {
    Name = "khaleel-strapi-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}