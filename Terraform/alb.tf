resource "aws_lb" "khaleel_strapi_alb" {
  name               = "khaleel-strapi-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = data.aws_subnets.default.ids
  security_groups = [aws_security_group.strapi_alb_sg.id]

  tags = {
    Name = "khaleel-strapi-alb"
  }
}

resource "aws_lb_target_group" "khaleel_strapi_tg" {
  name        = "khaleel-strapi-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/admin"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "khaleel-strapi-tg"
  }
}

resource "aws_lb_listener" "khaleel_http_listener" {
  load_balancer_arn = aws_lb.khaleel_strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.khaleel_strapi_tg.arn
  }
}
