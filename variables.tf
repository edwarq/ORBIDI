variable "region" {
  description = "La región de AWS donde se desplegarán los recursos."
  type        = string
}

variable "availability_zones" {
  description = "Las zonas de disponibilidad para la infraestructura"
  type        = list(string)
}

variable "instance_name" {
  description = "Nombre de la instancia bastión"
  type        = string
  default     = "bastion_rds"
}

variable "ami_id" {
  description = "Ami Id para el ambiente"
  type        = string
}

variable "ec2_type" {
  description = "Talla Ec2 - Ecs"
  type        = string
}

variable "environment" {
  description = "El ambiente en el que se desplegará: dev o prod"
  type        = string
  default     = "dev"
}

# VPC y subredes
variable "vpc_cidr" {
  description = "El CIDR de la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_public_1_cidr" {
  description = "El CIDR de la primera subred pública."
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_public_2_cidr" {
  description = "El CIDR de la segunda subred pública."
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_private_1_cidr" {
  description = "El CIDR de la primera subred privada."
  type        = string
  default     = "10.0.3.0/24"
}

variable "subnet_private_2_cidr" {
  description = "El CIDR de la segunda subred privada."
  type        = string
  default     = "10.0.4.0/24"
}

variable "ssh_access_ip_ssh" {
  description = "ip autorizada para admin por ssh"
  type        = string
  default     = "186.80.29.73/32"  # Mi Ip
}

variable "container_image" {
  description = "URL de la imagen del contenedor en ECR"
  type        = string
}

variable "ssh_access_ip_4580" {
  description = "puerto NAT acceso a DB"
  type        = string
  default     = "186.80.29.73/32"  # Mi Ip
}

