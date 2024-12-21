

# 16. Crear el Auto Scaling Group (ASG) con ECS
resource "aws_launch_template" "ecs_launch_config" {
  name = "ecs-launch-config"

  image_id        = var.ami_id  # Usamos la variable ami_id
  instance_type   = var.ec2_type
  vpc_security_group_ids  = [aws_security_group.ecs_sg.id]
  key_name        = aws_key_pair.keysshTFaws.key_name

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "ecs-instance"
      Environment = var.environment  # Etiqueta Ambiente
    }
  }
}



resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2

  launch_template {
    id      = aws_launch_template.ecs_launch_config.id
    version = "$Latest"
  }

  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  health_check_type          = "EC2"
  health_check_grace_period = 300
  force_delete               = true

  tag {
    key                 = "Name"
    value               = "ECSInstance"
    propagate_at_launch = true
  }
}


