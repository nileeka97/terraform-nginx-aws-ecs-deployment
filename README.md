# Terraform AWS ECS Infrastructure

This Terraform script sets up an ECS (Elastic Container Service) infrastructure on AWS, including a VPC, security group, ECS cluster, CloudWatch log group, ECS task definition, and ECS service. The script utilizes modules provided by the terraform-aws-modules community for VPC and security group configuration.

## Prerequisites

Before running this Terraform script, make sure you have the following:

- Terraform installed on your machine.
- AWS credentials configured on your machine.

## Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/nileeka97/terraform-nginx-aws-ecs-deployment
   cd terraform-nginx-aws-ecs-deployment


2. Create a terraform.tfvars file and provide necessary variables:
    
    ```hcl
    project_name            = "your-project-name"
    env                     = "your-environment"
    vpc_cidr_block          = "10.0.0.0/16"
    avail_zone_1            = "us-east-1a"
    avail_zone_2            = "us-east-1b"
    public_subnet_1_cidr_block = "10.0.1.0/24"
    public_subnet_2_cidr_block = "10.0.2.0/24"
    private_subnet_1_cidr_block = "10.0.3.0/24"
    alb_sg_port          = "80"
    container_port       = "80"
    awslogs_region       = "ap-south-1"   #same as aws ecs region
    docker_image_name    = "nginx:latest" # Replace with your desired Docker image
    cpu                  = "256"
    memory               = "512"
    s3_env_vars_file_arn = "arn:aws:s3:::demo-project-dev-env-vars/vars.env"
    health_check_path    = "/"

3. Run the following commands:
    
    ```hcl
    terraform init
    terraform apply

This will create the defined infrastructure on AWS.


## Cleanup
To destroy the created resources and avoid incurring costs:
    
    ```hcl
    terraform destroy

## Modules

### VPC Module
The VPC module is sourced from terraform-aws-modules/vpc/aws and creates a Virtual Private Cloud with specified subnets, availability zones, and resource tags.

### Security Group Module
The Security Group module is sourced from terraform-aws-modules/security-group/aws and configures a security group with ingress and egress rules.

### ECS Cluster
The ECS Cluster is created using the aws_ecs_cluster resource.

### CloudWatch Log Group
A CloudWatch log group is defined using the aws_cloudwatch_log_group resource to store container logs.

### ECS Task Definition
The ECS Task Definition is configured with container definitions, resource requirements, and CloudWatch log settings.

### ECS Service
The ECS Service is set up with Fargate launch type, specifying network configuration and associating it with the previously defined ECS cluster and task definition.

### Target Group
This module creates an ECS target group associated with the Application Load Balancer.

### Load Balancer
This module creates an Application Load Balancer (ALB) for your ECS services. Adjust the settings as per your requirements.

### LB Listener
This resource creates a listener for the ALB. In this example, it's set up for HTTP traffic on port 80 and forwards it to the ECS target group