
# 4. Crear la VPC con subredes públicas y privadas
resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_cidr  # Usamos la variable CIDR de la VPC
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name        = "devopsvpc"
    Environment = var.environment  # Etiqueta Ambiente
  }
}

# 5. Crear subredes públicas y privadas usando las zonas de disponibilidad de las variables
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.subnet_public_1_cidr  # Usamos la variable para CIDR
  availability_zone       = element(var.availability_zones, 0)  # Usamos la primera zona de la lista
  map_public_ip_on_launch = true
  tags = {
    Name        = "public-subnet-1"
    Environment = var.environment  # Etiqueta Ambiente
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.subnet_public_2_cidr  # Usamos la variable para CIDR
  availability_zone       = element(var.availability_zones, 1)  # Usamos la segunda zona de la lista
  map_public_ip_on_launch = true
  tags = {
    Name        = "public-subnet-2"
    Environment = var.environment  # Etiqueta Ambiente
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.subnet_private_1_cidr  # Usamos la variable para CIDR
  availability_zone       = element(var.availability_zones, 0)  # Usamos la primera zona de la lista
  tags = {
    Name        = "private-subnet-1"
    Environment = var.environment  # Etiqueta Ambiente
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.subnet_private_2_cidr  # Usamos la variable para CIDR
  availability_zone       = element(var.availability_zones, 1)  # Usamos la segunda zona de la lista
  tags = {
    Name        = "private-subnet-2"
    Environment = var.environment  # Etiqueta Ambiente
  }
}

# 6. Crear puerta de enlace de internet para las subredes públicas
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name        = "test-internet-gateway"
    Environment = var.environment  # Etiqueta Ambiente
  }
}

# 7. Crear Elastic IP para el NAT Gateway
resource "aws_eip" "nat_ip" {
  domain = "vpc"  
}

# 8. Crear el NAT Gateway para las redes privadas
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_ip.id  # Usamos el ID Elastic IP
  subnet_id     = aws_subnet.public_subnet_1.id  # El NAT Gateway en subred pública
  depends_on    = [aws_internet_gateway.internet_gateway]  # Internet Gateway
}


# 9. Crear las tablas de enrutamiento para las redes públicas y privadas

## Tabla de enrutamiento para las subredes públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = "public-route-table"
    Environment = var.environment
  }
}

## Tabla de enrutamiento para las subredes privadas

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id  # Ruta a través del NAT Gateway
  }

  tags = {
    Name        = "private-route-table"
    Environment = var.environment
  }
}


# 10. Asociar la tabla de enrutamiento pública con las subredes públicas
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# 11. Asociar la tabla de enrutamiento privada con las subredes privadas
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
