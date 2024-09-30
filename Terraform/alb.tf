
resource "aws_lb" "webapp_alb" {
  name               = "webapp-dev-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webapp_sg.id]
  subnets = [
    aws_subnet.public_subnets["public_subnet_1"].id,
    aws_subnet.public_subnets["public_subnet_2"].id,
    aws_subnet.public_subnets["public_subnet_3"].id
  ]
  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.webapp_dev_s3.bucket
    enabled = true
  }
}

#Target Group for the Application Load Balancer
resource "aws_lb_target_group" "webapp_tg" {
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name        = "webapp-dev-tg"
    Environment = "Dev"
  }
}

#Listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}

#Attach the ASG as the target group for the load balancer
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  lb_target_group_arn    = aws_lb_target_group.webapp_tg.arn
}