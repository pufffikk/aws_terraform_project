resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "postgres" {
  identifier              = "private-postgres"
  engine                  = "postgres"
  engine_version          = "17.4"
  instance_class          = "db.t3.micro" 
  allocated_storage       = 20            
  storage_type            = "gp2"         
  publicly_accessible     = false
  multi_az                = false         
  availability_zone       = "us-west-2a"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_name                 = "postgres"
  username                = "postgres"
  password                = "12345678"
  skip_final_snapshot     = true
  deletion_protection     = false
}

resource "aws_route53_zone" "main" {
  name = "quizgameruslan.com"
  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "db_alias" {
  zone_id = aws_route53_zone.main.id
  name    = "db.quizgameruslan.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.postgres.address]
}
