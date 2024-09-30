#Launch Configuration
resource "aws_launch_template" "webapp_lt" {
  name          = "webapp-launch-template"
  image_id      = data.vault_generic_secret.ami_id.data["ami_id"]
  instance_type = data.vault_generic_secret.instance_type.data["instance_type"]
  key_name      = "MyAWSKey"
  network_interfaces {
    associate_public_ip_address = "true"
    security_groups             = [aws_security_group.webapp_sg.id]
    subnet_id                   = aws_subnet.public_subnets["public_subnet_1"].id
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "webapp-dev-lt"
      Environment = "Dev"
    }
  }
  user_data = filebase64("${path.module}/user-data.sh")
  lifecycle {
    create_before_destroy = true
  }
}

#Autoscaling group
resource "aws_autoscaling_group" "webapp_asg" {
  max_size                  = 4
  min_size                  = 1
  health_check_type         = "ELB"
  health_check_grace_period = "300"
  desired_capacity          = 2
  vpc_zone_identifier = [
    aws_subnet.public_subnets["public_subnet_1"].id,
    aws_subnet.public_subnets["public_subnet_2"].id,
    aws_subnet.public_subnets["public_subnet_3"].id,
  ]
  launch_template {
    id      = aws_launch_template.webapp_lt.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "webapp-dev-asg"
    propagate_at_launch = true
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale_out_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale_in_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}