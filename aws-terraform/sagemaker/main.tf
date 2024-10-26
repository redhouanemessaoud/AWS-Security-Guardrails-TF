# AWS SageMaker Secure Configuration

# sagemaker:001: Enable network isolation for Amazon SageMaker Training jobs
resource "aws_sagemaker_training_job" "training_job" {
  training_job_name = var.training_job_name
  # ... other configurations ...
  enable_network_isolation = true
}

# sagemaker:002: Configure multiple instances for SageMaker endpoint production variants
resource "aws_sagemaker_endpoint_configuration" "endpoint_config" {
  name = var.endpoint_config_name

  production_variants {
    variant_name           = "variant-1"
    model_name             = var.model_name
    initial_instance_count = var.initial_instance_count
    instance_type          = var.instance_type
  }
}

# sagemaker:003: Configure VPC settings for Amazon SageMaker Models
# sagemaker:008: Enable network isolation for Amazon SageMaker Models
resource "aws_sagemaker_model" "model" {
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

# sagemaker:004: Enable KMS encryption for Amazon SageMaker Training job volumes and outputs
# sagemaker:005: Configure VPC settings for Amazon SageMaker Training jobs
# sagemaker:007: Enable intercontainer encryption for Amazon SageMaker Training jobs
resource "aws_sagemaker_training_job" "training_job_with_encryption" {
  training_job_name = var.training_job_name
  # ... other configurations ...

  vpc_config {
    subnets            = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  resource_config {
    instance_type  = var.training_instance_type
    instance_count = var.training_instance_count
    volume_size_in_gb = var.volume_size_in_gb
    volume_kms_key_id = var.kms_key_id
  }

  output_data_config {
    kms_key_id = var.kms_key_id
  }

  enable_inter_container_traffic_encryption = true
}

# sagemaker:006: Disable root access for Amazon SageMaker Notebook instances
# sagemaker:009: Disable direct internet access for Amazon SageMaker Notebook instances
# sagemaker:010: Enable KMS encryption for Amazon SageMaker Notebook instances
# sagemaker:011: Configure VPC settings for Amazon SageMaker Notebook instances
# sagemaker:018: Enable IMDSv2 for Amazon SageMaker Notebook Instances
resource "aws_sagemaker_notebook_instance" "notebook" {
  name                    = var.notebook_name
  instance_type           = var.notebook_instance_type
  role_arn                = var.notebook_role_arn
  kms_key_id              = var.kms_key_id
  root_access             = "Disabled"
  direct_internet_access  = false
  subnet_id               = var.subnet_id
  security_groups         = var.security_group_ids
  instance_metadata_service_configuration {
    minimum_instance_metadata_service_version = "2"
  }
}

# sagemaker:012: Enable encryption for inter-instance communication in Amazon SageMaker Data Quality Jobs
# sagemaker:013: Enable KMS encryption for Amazon SageMaker Data Quality Job storage volumes
# sagemaker:014: Enable KMS encryption for Amazon SageMaker Data Quality Job model artifacts
resource "aws_sagemaker_data_quality_job_definition" "data_quality_job" {
  name                = var.data_quality_job_name
  role_arn            = var.data_quality_role_arn

  data_quality_app_specification {
    image_uri = var.data_quality_image_uri
  }

  data_quality_job_input {
    # ... input configuration ...
  }

  data_quality_job_output_config {
    kms_key_id = var.kms_key_id
  }

  job_resources {
    cluster_config {
      instance_count    = var.data_quality_instance_count
      instance_type     = var.data_quality_instance_type
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

# sagemaker:015: Enable KMS encryption for Amazon SageMaker Domain
resource "aws_sagemaker_domain" "domain" {
  domain_name = var.domain_name
  auth_mode   = "IAM"
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  default_user_settings {
    execution_role = var.execution_role_arn
  }

  kms_key_id = var.kms_key_id
}

# sagemaker:016: Enable KMS encryption for Amazon SageMaker Endpoints
resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = var.endpoint_name
  endpoint_config_name = aws_sagemaker_endpoint_configuration.endpoint_config.name

  deployment_config {
    auto_rollback_configuration {
      alarms = var.alarm_names
    }
    blue_green_update_policy {
      traffic_routing_configuration {
        type                     = "ALL_AT_ONCE"
        wait_interval_in_seconds = 0
      }
    }
  }
}

# sagemaker:017: Enable KMS encryption for Amazon SageMaker Flow Definition outputs
resource "aws_sagemaker_flow_definition" "flow_definition" {
  flow_definition_name = var.flow_definition_name
  role_arn             = var.flow_definition_role_arn

  human_loop_config {
    human_task_ui_arn     = var.human_task_ui_arn
    task_count            = var.task_count
    task_description      = var.task_description
    task_title            = var.task_title
    workflow_arn          = var.workflow_arn
  }

  output_config {
    s3_output_path = var.s3_output_path
    kms_key_id     = var.kms_key_id
  }
}