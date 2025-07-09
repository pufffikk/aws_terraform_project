resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "postgres" {
  identifier              = "private-postgres"
  engine                  = "postgres"
  engine_version          = "15.5"
  instance_class          = "db.t3.micro"
  allocated_storage       = 10
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  username                = "postgres"
  password                = "12345678"
  db_name                 = "postgres"
  skip_final_snapshot     = true
  publicly_accessible     = false
}

resource "aws_route53_zone" "main" {
  name = "quizgameruslan.com"
}

resource "aws_route53_record" "db_alias" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "db.quizgameruslan.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.postgres.address]
}
