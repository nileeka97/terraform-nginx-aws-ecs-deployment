# Define VPC using the terraform-aws-modules/vpc/aws module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  # Set VPC name and CIDR block
  name = "ecs-vpc"
  cidr = var.vpc_cidr_block

  # Specify availability zones and subnets
  azs            = [var.avail_zone_1,var.avail_zone_2]
  public_subnets = [var.public_subnet_1_cidr_block,var.public_subnet_2_cidr_block]
  private_subnets = [var.private_subnet_1_cidr_block]

  # Set tags for various resources within the VPC
  public_subnet_tags          = { Name = "${var.project_name}-${var.env}-public-subnet-1" }
  igw_tags                    = { Name = "${var.project_name}-${var.env}-igw" }
  default_security_group_tags = { Name = "${var.project_name}-${var.env}-default-sg" }
  default_route_table_tags    = { Name = "${var.project_name}-${var.env}-main-rtb" }
  public_route_table_tags     = { Name = "${var.project_name}-${var.env}-public-rtb" }

  # Set overall tags for the VPC
  tags = {
    Name = "${var.project_name}-${var.env}-vpc"
  }
}