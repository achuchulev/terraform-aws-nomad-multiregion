// AWS VARs

# Networking
variable "access_key" {}
variable "secret_key" {}
variable "aws_region_a" {}
variable "aws_region_b" {}

variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_zone" {}
variable "aws_subdomain_name_a" {}
variable "aws_subdomain_name_b" {}

variable "vpc_tag_name" {
  description = "Set a VPC Name tag"
  default     = "nomad-network"
}

variable "vpc_tag_side_a" {
  description = "Set a VPC Side tag"
  default     = "accepter"
}

variable "vpc_tag_side_b" {
  description = "Set a VPC Side tag"
  default     = "requester"
}

variable "vpc_cidr_block_a" {
  description = "Define requester VPC cidr blocks"
  default     = "10.100.0.0/16"
}

variable "vpc_subnet_cidr_blocks_a" {
  type        = list(string)
  description = "Define VPC subnet cidr blocks"
  default     = ["10.100.0.0/24", "10.100.1.0/24"]
}

variable "vpc_cidr_block_b" {
  description = "Define requester VPC cidr blocks"
  default     = "10.200.0.0/16"
}

variable "vpc_subnet_cidr_blocks_b" {
  type        = list(string)
  description = "Define VPC subnet cidr blocks"
  default     = ["10.200.0.0/24", "10.200.1.0/24"]
}

variable "nomad_region_aws_a" {
  default = "aws.a"
}

variable "nomad_region_aws_b" {
  default = "aws.b"
}

variable "authoritative_region" {
  default = "aws"
}

variable "ami_nomad_server_a" {}
variable "ami_nomad_client_a" {}
variable "ami_frontend_a" {}
variable "ami_nomad_server_b" {}
variable "ami_nomad_client_b" {}
variable "ami_frontend_b" {}
