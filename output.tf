output "vpc_id" {
  description = "ID da VPC"
  value       = data.aws_vpc.main.id
}

output "database_instance_id" {
  description = "ID da instancia do banco de dados"
  value       = aws_db_instance.rds.id
}

