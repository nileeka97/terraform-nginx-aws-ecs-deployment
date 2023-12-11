# Define Security Group using terraform-aws-modules/security-group/aws module
module "container-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  # Set Security Group name and associate it with the VPC created above
  name   = "${var.project_name}-${var.env}-ecs-sg"
  vpc_id = module.vpc.vpc_id

  # Configure ingress and egress rules for the Security Group
  ingress_with_cidr_blocks = [
    {
      from_port   = var.container_port
      to_port     = var.container_port
      protocol    = "tcp"
      description = "con sg ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  # Set tags for the Security Group
  tags = {
    Name = "${var.project_name}-${var.env}-ecs-sg"
  }
}


module "alb-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  # Set Security Group name and associate it with the VPC created above
  name   = "${var.project_name}-${var.env}-alb-sg"
  vpc_id = module.vpc.vpc_id

  # Configure ingress and egress rules for the Security Group
  ingress_with_cidr_blocks = [
    {
      from_port   = var.alb_sg_port
      to_port     = var.alb_sg_port
      protocol    = "tcp"
      description = "elb sg port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  # Set tags for the Security Group
  tags = {
    Name = "${var.project_name}-${var.env}-alb-sg"
  }
}