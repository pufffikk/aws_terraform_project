resource "aws_autoscaling_group" "app_asg" {
  name                      = "quiz-game-asg"
  max_size                  = 6
  min_size                  = 1
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.public_subnets

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "quiz-game-asg-instance"
    propagate_at_launch = true
  }
}
