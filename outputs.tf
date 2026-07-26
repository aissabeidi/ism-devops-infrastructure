output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.main.bucket
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.web.public_ip}"
}