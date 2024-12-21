##########

# Crear VPC, Subredes, Internet Gateway, NAT Gateway, etc. (esto ya lo tienes configurado)

# Crear el ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "testdevops"
}



# Configurar el listener HTTP que redirige a HTTPS
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}


# Generar la clave privada RSA
resource "tls_private_key" "testdevops" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generar el certificado auto-firmado usando la clave privada
resource "tls_self_signed_cert" "testdevops" {
  private_key_pem = tls_private_key.testdevops.private_key_pem

  subject {
    common_name  = "testdevops.com"  
    organization = "TestDevOps, Inc"  
  }

  validity_period_hours = 8760  # Certificado válido por 1 año (8760 horas)

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",  # Usado para HTTPS
  ]
}

# Importar el certificado a AWS ACM
resource "aws_acm_certificate" "testdevops_cert" {
  private_key      = tls_private_key.testdevops.private_key_pem
  certificate_body = tls_self_signed_cert.testdevops.cert_pem
  
  tags = {
    Name = "testdevops-cert"
  }
}

# Output: Mostrar ARN del certificado generado
output "certificate_arn" {
  value = aws_acm_certificate.testdevops_cert.arn
}


######################

# Crear el ECS Service que se ejecutará en el ECS Cluster
resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id  # Referencia al ECS Cluster creado
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2  # Número de instancias de contenedores que deseas ejecutar
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn  # ARN del target group
    container_name   = "my-container"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.alb_listener_https,  # Aseguramos que el ALB esté configurado antes de crear el servicio ECS
    aws_lb_target_group.alb_target_group  # Aseguramos que el target group esté creado antes del servicio ECS
  ]
}

# Crear el Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "testdevops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false
}

# Crear el Target Group de ALB
resource "aws_lb_target_group" "alb_target_group" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"  
  vpc_id      = aws_vpc.test_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Configurar el listener HTTPS del ALB
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn  # ARN de tu Application Load Balancer
  port              = 443             # El puerto de HTTPS
  protocol          = "HTTPS"         # El protocolo HTTPS
  ssl_policy        = "ELBSecurityPolicy-2016-08"  # Política de seguridad para SSL
  certificate_arn   = aws_acm_certificate.testdevops_cert.arn  # ARN del certificado generado en ACM

  # Aquí solo debe haber una acción de tipo 'forward' al target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn  # Asociamos el target group con el listener
  }
}


# Crear la Task Definition de ECS
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "my-task"
  container_definitions    = jsonencode([{
    name      = "my-container"
    image     = var.container_image  # Usando la variable para la imagen
    memory    = 512
    cpu       = 256
    essential = true
    portMappings = [
      {
        containerPort = 80  # Puerto expuesto por el contenedor (Django)
        hostPort      = 80  # Puerto en el host que se mapeará
        protocol      = "tcp"
      }
    ]
  }])
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  tags = {
    Name        = "MyTask"
    Environment = var.environment  # Etiqueta de ambiente
  }
}
