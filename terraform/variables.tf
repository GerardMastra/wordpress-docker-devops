variable "aws_region" {
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t3.small"
}

variable "key_name" {
  description = "Nombre de tu key pair en AWS"
}
