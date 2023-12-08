variable "project_name" {}
variable "env" {}
variable "vpc_cidr_block" {}
variable "avail_zone_1" {}
variable "avail_zone_2" {}
variable "private_subnet_1_cidr_block" {}
variable "public_subnet_1_cidr_block" {}
variable "public_subnet_2_cidr_block" {}
variable "sg_port" {}

variable "container_port" {}
variable "host_port" {}
variable "awslogs_region" {}
variable "docker_image_name" {}
variable "cpu" {}
variable "memory" {}