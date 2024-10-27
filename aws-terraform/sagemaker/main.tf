# AWS SageMaker Secure Configuration

# sagemaker:001: Enable network isolation for SageMaker Training jobs
resource "aws_sagemaker_training_job" "main" {
  training_job_name = var.training_job_name
  # ... other configuration ...
  enable_network_isolation = true
}

# sagemaker:002: Configure multiple instances for SageMaker endpoint production variants
resource "aws_sagemaker_endpoint_configuration" "main" {
  name = var.endpoint_config_name

  production_variants {
    variant_name           = "variant-1"
    model_name             = var.model_name
    initial_instance_count = var.initial_instance_count
    instance_type          = var.instance_type
  }
}

# sagemaker:003: Configure VPC settings for SageMaker Models
# sagemaker:008: Enable network isolation for SageMaker Models
resource "aws_sagemaker_model" "main" {
  name               = var.model_name
  execution_role_arn = var.execution_role_arn

  primary_container {
    image = var.container_image
  }

  vpc_config {
    subnets            = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  enable_network_isolation = true
}

# sagemaker:004: Enable KMS encryption for SageMaker Training job volumes and outputs
# sagemaker:005: Configure VPC settings for SageMaker Training jobs
# sagemaker:007: Enable inter-container encryption for SageMaker Training jobs
resource "aws_sagemaker_training_job" "secure" {
  training_job_name = var.training_job_name
  role_arn          = var.execution_role_arn

  algorithm_specification {
    training_image = var.training_image
    training_input_mode = "File"
  }

  resource_config {
    instance_count  = var.instance_count
    instance_type   = var.instance_type
    volume_size_in_gb = var.volume_size_in_gb
  }

  vpc_config {
    subnets            = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  output_data_config {
    kms_key_id = var.kms_key_id
    s3_output_path = var.s3_output_path
  }

  enable_inter_container_traffic_encryption = true
  enable_network_isolation = true

  encrypt_inter_container_traffic = true
}

# sagemaker:006: Disable root access for SageMaker Notebook instances
# sagemaker:009: Disable direct internet access for SageMaker Notebook instances
# sagemaker:010: Enable KMS encryption for SageMaker Notebook instances
# sagemaker:011: Configure VPC settings for SageMaker Notebook instances
# sagemaker:018: Enforce IMDSv2 for SageMaker Notebook Instances
resource "aws_sagemaker_notebook_instance" "main" {
  name                    = var.notebook_instance_name
  instance_type           = var.notebook_instance_type
  role_arn                = var.notebook_role_arn
  kms_key_id              = var.kms_key_id
  subnet_id               = var.subnet_id
  security_groups         = var.security_group_ids
  root_access             = "Disabled"
  direct_internet_access  = false
  instance_metadata_service_configuration {
    minimum_instance_metadata_service_version = "2"
  }
}

# sagemaker:012: Enable inter-instance encryption for SageMaker Data Quality monitoring jobs
# sagemaker:013: Enable KMS encryption for SageMaker Data Quality job storage volumes
# sagemaker:014: Enable KMS encryption for SageMaker Data Quality job model artifacts
resource "aws_sagemaker_data_quality_job_definition" "main" {
  name                = var.data_quality_job_name
  role_arn            = var.execution_role_arn

  data_quality_app_specification {
    image_uri = var.data_quality_image_uri
  }

  data_quality_job_input {
    endpoint_name = var.endpoint_name
  }

  data_quality_job_output_config {
    kms_key_id        = var.kms_key_id
    s3_output_path    = var.s3_output_path
  }

  job_resources {
    cluster_config {
      instance_count    = var.instance_count
      instance_type     = var.instance_type
      volume_kms_key_id = var.kms_key_id
    }
  }

  network_config {
    enable_inter_container_traffic_encryption = true
    enable_network_isolation                  = true
    vpc_config {
      subnets            = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
}

# sagemaker:015: Enable KMS encryption for SageMaker Domain
resource "aws_sagemaker_domain" "main" {
  domain_name = var.domain_name
  auth_mode   = "IAM"
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  default_user_settings {
    execution_role = var.execution_role_arn
  }

  kms_key_id = var.kms_key_id
}

# sagemaker:016: Enable KMS encryption for SageMaker Endpoints
resource "aws_sagemaker_endpoint" "main" {
  name                 = var.endpoint_name
  endpoint_config_name = aws_sagemaker_endpoint_configuration.main.name

  deployment_config {
    blue_green_update_policy {
      traffic_routing_configuration {
        type                     = "ALL_AT_ONCE"
        wait_interval_in_seconds = 0
      }
    }
    auto_rollback_configuration {
      auto_rollback = true
    }
  }

  data_capture_config {
    enable_capture = true
    initial_sampling_percentage = 100
    destination_s3_uri = var.data_capture_s3_uri
    kms_key_id = var.kms_key_id
  }
}

# sagemaker:017: Enable KMS encryption for SageMaker Flow Definition outputs
resource "aws_sagemaker_flow_definition" "main" {
  flow_definition_name = var.flow_definition_name
  role_arn             = var.execution_role_arn

  human_loop_config {
    human_task_ui_arn     = var.human_task_ui_arn
    task_title            = var.task_title
    task_description      = var.task_description
    task_count            = var.task_count
    task_availability_lifetime_in_seconds = var.task_availability_lifetime_in_seconds
    work_team_arn         = var.work_team_arn
  }

  output_config {
    s3_output_path = var.s3_output_path
    kms_key_id     = var.kms_key_id
  }
}