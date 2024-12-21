
#  Crear la base de datos RDS en una subred privada
resource "aws_db_instance" "db_instance" {
  identifier           = "mydbmysqldevops"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t4g.micro"
  db_name              = "mydbtestdevops"
  username             = "admin"
  password             = "mysecretpassword"
  publicly_accessible  = false
  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  tags = {
    Name        = "RDSInstance"
    Environment = var.environment  # Etiqueta Ambiente
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "mydbsubnetgroup-${random_id.subnet_group_id.hex}"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name        = "DB Subnet Group"
    Environment = var.environment
  }
}

resource "random_id" "subnet_group_id" {
  byte_length = 4
}
