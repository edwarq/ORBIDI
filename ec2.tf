resource "tls_private_key" "keysshTF" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.keysshTF.private_key_pem
  filename = "ssh_key/${var.instance_name}.pem"
}

resource "aws_key_pair" "keysshTFaws" {
  key_name   = "${var.instance_name}-key"
  public_key = tls_private_key.keysshTF.public_key_openssh
}

resource "aws_instance" "bastion_host" {
  ami             = var.ami_id
  instance_type   = var.ec2_type
  subnet_id       = aws_subnet.public_subnet_1.id
  key_name        = aws_key_pair.keysshTFaws.key_name
  security_groups = [aws_security_group.bastion_sg.id]
  tags = {
    Name        = "BastionHost"
    Environment = var.environment
  }
}
