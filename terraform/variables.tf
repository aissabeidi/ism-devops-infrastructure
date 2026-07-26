variable "aws_region" {
  description = "Region AWS de deploiement"
  type        = string
  default     = "eu-west-3" # Paris
}

variable "availability_zone" {
  description = "Zone de disponibilite du sous-reseau"
  type        = string
  default     = "eu-west-3a"
}

variable "project_name" {
  description = "Nom du projet, utilise comme prefixe pour toutes les ressources"
  type        = string
  default     = "memoire-lan-security"
}

variable "vpc_cidr" {
  description = "Bloc CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Bloc CIDR du sous-reseau public"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorise a se connecter en SSH (mettre TON_IP/32, jamais 0.0.0.0/0)"
  type        = string
  # A remplacer obligatoirement dans terraform.tfvars
}

variable "ssh_public_key_path" {
  description = "Chemin local vers la cle publique SSH (ex: ~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
