variable "project_name" {
  default = "ism-devops"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "public_key_path" {
  default = "C:/Users/X1 Carbon/.ssh/id_rsa.pub"
}
variable "public_key_content" {
  description = "Contenu de la clé publique SSH"
  type        = string
  default     = ""
}