# Define an ECS cluster with a name based on project and environment variables
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project_name}-${var.env}-cluster"
}


# Define a CloudWatch log group with a name based on project and environment variables
resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name = "/ecs/${var.project_name}-${var.env}-task-definition"
}


# Define an ECS task definition with necessary configurations, including container definitions
resource "aws_ecs_task_definition" "ecs-task" {
  family                   = "${var.project_name}-${var.env}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu    # CPU units for the task
  memory                   = var.memory # Memory in MiB for the task
  execution_role_arn       = "arn:aws:iam::206127768080:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::206127768080:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name  = "${var.project_name}-${var.env}-con"
      image = var.docker_image_name # Replace with your desired Docker image
      essential : true

      portMappings = [
        {
          containerPort = tonumber(var.container_port)
          hostport      = tonumber(var.container_port)
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ],

      # Add environment variables file from S3
      environmentFiles = [
        {
          value = var.s3_env_vars_file_arn,
          type  = "s3"
        }
      ],

      # Configure AWS CloudWatch Logs for container
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = aws_cloudwatch_log_group.ecs-log-group.name
          "awslogs-region"        = var.awslogs_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


# Define an ECS service with Fargate launch type, specifying network configuration
resource "aws_ecs_service" "ecs-service" {
  name            = "demo-project-dev-service"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task.arn
  desired_count   = 1

  # Configure network settings for the ECS service
  network_configuration {
    assign_public_ip = true
    subnets          = [module.vpc.public_subnets[0]]                      # Replace with your subnet IDs
    security_groups  = [module.container-security-group.security_group_id] # Replace with your security group ID
  }

  # Configure load balancing for the ECS service
  health_check_grace_period_seconds = 0
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-target-group.arn
    container_name   = "${var.project_name}-${var.env}-con"
    container_port   = var.container_port
  }
}


# Define an Application Load Balancer (ALB)
resource "aws_lb" "ecs-alb" {
  name               = "${var.project_name}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb-security-group.security_group_id]                # Replace with your security group ID
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]] # Replace with your subnet IDs
}


# Define a Target Group
resource "aws_lb_target_group" "ecs-target-group" {
  name        = "${var.project_name}-${var.env}-target-group"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id # Replace with your VPC ID

  health_check {
    path                = var.health_check_path # Replace with your health check path
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Attach Target Group to the Load Balancer
resource "aws_lb_listener" "ecs-listener" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-target-group.arn
  }
}
