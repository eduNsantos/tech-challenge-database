

resource "aws_db_instance" "rds" {
  allocated_storage       = 10
  db_name                 = var.db_name
  engine                  = "mysql"
  engine_version          = "8.0.46"
  instance_class          = "db.t3.micro"
  username                = var.db_user
  password                = var.db_password
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  publicly_accessible     = false
  vpc_security_group_ids = [data.aws_security_group.rds.id]

  db_subnet_group_name = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [data.aws_subnet.sub_a.id, data.aws_subnet.sub_b.id]

  tags = {
    Name = "My DB subnet group"
  }
}