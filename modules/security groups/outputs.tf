output "web_sg_id" {
  description = "Web Security Group ID"
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "Database Security Group ID"
  value       = aws_security_group.db.id
}

output "web_sg_name" {
  description = "Web Security Group Name"
  value       = aws_security_group.web.name
}

output "db_sg_name" {
  description = "Database Security Group Name"
  value       = aws_security_group.db.name
}