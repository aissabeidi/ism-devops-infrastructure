output "instance_public_ip" {
  description = "IP publique de l'instance EC2 (utilisee par Ansible)"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.web.id
}

output "s3_bucket_name" {
  description = "Nom du bucket S3 cree"
  value       = aws_s3_bucket.artifacts.bucket
}

output "security_group_id" {
  description = "ID du security group"
  value       = aws_security_group.web.id
}
