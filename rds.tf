

resource "aws_db_instance" "rds" {
  identifier = "techchallenge-rds"
  allocated_storage       = 10
  db_name                 = var.db_name
  engine                  = "mysql"
  engine_version          = "8.0.46"
  instance_class          = "db.t3.micro"
  username                = var.db_user
  password                = var.db_password
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  publicly_accessible     = true
  vpc_security_group_ids = [data.aws_security_group.rds.id]

  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = {
    Name = "Main RDS"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [data.aws_subnet.sub_a.id, data.aws_subnet.sub_b.id]

  tags = {
    Name = "Main subnet group"
  }
}

# Regra adicional, independente do SG existente (data source): libera 3306 para
# toda a VPC como default temporário até sabermos o SG do Lambda de autenticação.
resource "aws_vpc_security_group_ingress_rule" "rds_mysql_from_vpc" {
  security_group_id = data.aws_security_group.rds.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = data.aws_vpc.main.cidr_block
  description       = "MySQL access from within the VPC (temporary, for tech-challenge-lambda-functions)"
}
