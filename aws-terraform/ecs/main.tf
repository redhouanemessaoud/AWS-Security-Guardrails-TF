# AWS ECS Security Configuration

# ECS:001 - Avoid storing secrets in ECS task definition environment variables
# ECS:013 - Use separate IAM roles for ECS task execution and task functionality
resource "aws_ecs_task_definition" "main" {
  family                   = var.task_definition_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.container_image

      # ECS:004 - Prevent the use of privileged containers in ECS task definitions
      # ECS:006 - Enforce read-only root filesystem for ECS containers
      # ECS:007 - Prevent ECS task definitions from sharing the host's process namespace
      privileged            = false
      readonlyRootFilesystem = true
      pid_mode              = "task"

      # ECS:008 - Implement logging configuration for ECS task definition containers
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.cloudwatch_log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      # ECS:012 - Enable encryption in transit for EFS volumes in ECS task definitions
      mountPoints = var.efs_volume_name != "" ? [
        {
          sourceVolume  = var.efs_volume_name
          containerPath = var.efs_container_path
          readOnly      = false
        }
      ] : []
    }
  ])

  # ECS:012 - Enable encryption in transit for EFS volumes in ECS task definitions
  dynamic "volume" {
    for_each = var.efs_volume_name != "" ? [1] : []
    content {
      name = var.efs_volume_name

      efs_volume_configuration {
        file_system_id     = var.efs_file_system_id
        root_directory     = "/"
        transit_encryption = "ENABLED"
      }
    }
  }
}

# ECS:003 - Disable automatic public IP assignment for ECS services
# ECS:009 - Use the latest Fargate platform version for ECS Fargate services
# ECS:015 - Implement ECS task networking using awsvpc network mode
resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count

  launch_type         = "FARGATE"
  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }
}

# ECS:005 - Enable Container Insights for ECS clusters
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS:010 - Enable ECS Exec logging
# ECS:011 - Use AWS KMS Customer Managed Keys for ECS Exec logging encryption
resource "aws_ecs_cluster_configuration" "main" {
  cluster_name = aws_ecs_cluster.main.name

  execute_command_configuration {
    logging = "OVERRIDE"
    log_configuration {
      cloud_watch_encryption_enabled = true
      cloud_watch_log_group_name     = var.ecs_exec_log_group_name
      s3_bucket_name                 = var.ecs_exec_s3_bucket_name
      s3_key_prefix                  = var.ecs_exec_s3_key_prefix
      s3_bucket_encryption_enabled   = true
    }
    kms_key_id = var.kms_key_arn
  }
}