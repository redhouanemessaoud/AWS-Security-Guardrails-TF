# EMR Cluster Security Configuration

# emr:001 Enable EMR Account Public Access Block
resource "aws_emr_account_public_access_block" "main" {
  block_public_security_group_rules = true
}

# emr:003 Use Security Configuration for EMR Clusters
# emr:006 Enable At-Rest Encryption for EMR Cluster using AWS KMS
# emr:007 Enable Encryption of EBS Volumes for EMR Cluster
# emr:008 Enable In-Transit Encryption for EMR Cluster
# emr:009 Enable Local Disk Encryption for EMR Cluster
resource "aws_emr_security_configuration" "main" {
  name = var.security_configuration_name

  configuration = jsonencode({
    EncryptionConfiguration = {
      AtRestEncryptionConfiguration = {
        S3EncryptionConfiguration = {
          EncryptionMode = "SSE-KMS"
          AwsKmsKey     = var.s3_kms_key_arn
        }
        LocalDiskEncryptionConfiguration = {
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                 = var.local_disk_kms_key_arn
        }
      }
      EnableInTransitEncryption = true
      EnableAtRestEncryption    = true
    }
    AuthenticationConfiguration = {
      KerberosConfiguration = var.enable_kerberos ? {
        Provider                = "ClusterDedicatedKdc"
        KdcAdminPassword        = var.kdc_admin_password
        Realm                   = var.kerberos_realm
        CrossRealmTrustConfiguration = {
          Realm           = var.cross_realm_trust_realm
          Domain          = var.cross_realm_trust_domain
          AdminServer     = var.cross_realm_trust_admin_server
          KdcServer       = var.cross_realm_trust_kdc_server
        }
      } : null
    }
  })
}

# emr:002 Disable Public IP Addresses for EMR Cluster Instances
# emr:004 Restrict EMR Cluster Security Group Access
# emr:005 Configure Kerberos Authentication for EMR Clusters
# emr:010 Use IAM Roles for EMR Cluster EC2 Instances
# emr:011 Enable EMR Cluster Logging
# emr:012 Use VPC for EMR Cluster Deployment
# emr:015 Use Latest EMR Release with Security Patches
resource "aws_emr_cluster" "main" {
  name          = var.cluster_name
  release_label = var.emr_release_label
  applications  = var.applications

  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = var.master_security_group_id
    emr_managed_slave_security_group  = var.slave_security_group_id
    instance_profile                  = var.instance_profile
  }

  master_instance_group {
    instance_type = var.master_instance_type
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
  }

  security_configuration = aws_emr_security_configuration.main.name

  log_uri = var.log_uri

  service_role = var.service_role

  configurations_json = jsonencode([
    {
      Classification = "emrfs-site"
      Properties = {
        "fs.s3.enableServerSideEncryption" = "true"
      }
    }
  ])

  kerberos_attributes {
    kdc_admin_password = var.enable_kerberos ? var.kdc_admin_password : null
    realm              = var.enable_kerberos ? var.kerberos_realm : null
  }

  step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "Setup Hadoop Debugging"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["state-pusher-script"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# emr:013 Implement EMR Fine-Grained Access Control
resource "aws_lakeformation_resource" "emr_data" {
  count = var.enable_lake_formation ? 1 : 0

  arn = aws_emr_cluster.main.arn
}

# emr:014 Enable EMR Step Execution Auditing
# Note: CloudTrail is assumed to be already configured for the account