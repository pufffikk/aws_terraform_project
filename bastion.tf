resource "aws_instance" "bastion" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type          = "t3.micro"
  key_name               = var.key_pair
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "Bastion Host"
  }
}