output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.postgresql.endpoint
}

output "rds_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.postgresql.address
}
