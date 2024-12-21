# 12. Crear el grupo de seguridad para la instancia Bastion (puerto 22)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH and custom access to Bastion Host"
  vpc_id      = aws_vpc.test_vpc.id
  tags = {
    Environment = var.environment  # Etiqueta Ambiente
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_ip_ssh]  # IP para acceso SSH (puerto 22)
  }

  ingress {
    from_port   = 4580
    to_port     = 4580
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_ip_4580]  # IP para acceso al puerto 4580
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Crear un grupo de seguridad
resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  description = "Security group for ALB and ECS"
  vpc_id      = aws_vpc.test_vpc.id  # Asegúrate de que la VPC esté definida correctamente

  # Reglas de entrada (Ingress)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas de salida (Egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Permite todo el tráfico saliente
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test_sg"
  }
}

# 15. Crear el Security Group para el ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP/HTTPS from internet to ALB"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# 17. Crear el Security Group para ECS
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow HTTP/HTTPS traffic from ALB"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Permite solo el tráfico del ALB
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Permite solo el tráfico del ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
