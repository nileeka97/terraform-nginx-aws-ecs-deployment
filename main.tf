# Define an ECS cluster with a name based on project and environment variables
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project_name}-${var.env}-cluster"
}


# Define a CloudWatch log group with a name based on project and environment variables
resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name = "${var.project_name}-${var.env}-task-definition"
}


# Define an ECS task definition with necessary configurations, including container definitions
resource "aws_ecs_task_definition" "ecs-task" {
  family                   = "${var.project_name}-${var.env}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu # CPU units for the task
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
          hostport      = tonumber(var.host_port)
          protocol      = "tcp"
          appProtocol   = "http"
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
    subnets          = [module.vpc.public_subnets[0]] # Replace with your subnet IDs
    security_groups  = [module.security-group.security_group_id] # Replace with your security group ID
  }
}

