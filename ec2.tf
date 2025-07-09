data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_pair
  associate_public_ip_address = true
  
  user_data                   = file("${path.module}/scripts/ec2_user_data.sh")

  depends_on = [
    aws_db_instance.postgres,
    aws_route53_record.db_alias
  ]
  tags = { Name = "ec2-public" }
}
