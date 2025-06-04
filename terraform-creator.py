import os
import json
import boto3
import re
from boto3 import client
from botocore.config import Config
import requests

# Configuration for the Bedrock client with extended read timeout
# This is necessary for handling large responses from the model
config = Config(read_timeout=1000)

# Initialize the Bedrock client for AWS services
# This client will be used to interact with the AWS Bedrock Runtime service
bedrock = boto3.client(service_name='bedrock-runtime',
                      region_name='us-east-1',
                      config=config)

# Model ID for Claude 3.5 Sonnet
# This specific model version is optimized for infrastructure and security tasks
model_id = "anthropic.claude-3-5-sonnet-20240620-v1:0"

def invoke_hf(prompt: str) -> str:
    """Invoke a Hugging Face text-generation model and return the generated text."""
    api_url = f"https://api-inference.huggingface.co/models/{HF_MODEL_ID}"
    headers = {}
    if HF_API_TOKEN:
        headers["Authorization"] = f"Bearer {HF_API_TOKEN}"
    response = requests.post(api_url, headers=headers, json={"inputs": prompt})
    response.raise_for_status()
    data = response.json()
    if isinstance(data, list) and data:
        return data[0].get("generated_text", "")
    return data.get("generated_text", "")

# Settings for Hugging Face API (optional)
HF_MODEL_ID = os.environ.get("HF_MODEL_ID", "HuggingFaceH4/zephyr-7b-beta")
HF_API_TOKEN = os.environ.get("HF_API_TOKEN")
USE_HF = os.environ.get("USE_HF", "false").lower() == "true"

def read_json_file(file_path):
    """
    Read and parse a JSON file containing security requirements.

    Args:
        file_path (str): Path to the JSON file containing security requirements.

    Returns:
        dict: Parsed JSON data containing security requirements.
        None: If file is not found or cannot be parsed.
    """
    try:
        with open(file_path, 'r') as file:
            data = json.load(file)
            return data
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return None
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        return None

def create_terraform_module(service_name, num_service_requirement, service_requirements, notes_format):
    """
    Generate a Terraform module based on provided security requirements.

    This function constructs a prompt for the LLM (Claude by default) to generate secure Terraform configurations.
    It includes detailed instructions about security best practices, implementation guidelines,
    and formatting requirements.

    Args:
        service_name (str): Name of the AWS service for which to generate the module.
        num_service_requirement (int): Number of security requirements to implement.
        service_requirements (list): List of security requirements for the service.
        notes_format (str): Template format for the notes.md file.

    Returns:
        str: Generated Terraform module content including main.tf, variables.tf, and notes.md.
    """
    # Construct the system prompt with detailed instructions for the LLM
    sys_prompt = f"""You are an expert in cloud security for AWS. You need to develop comprehensive, secure Terraform module for the given AWS service based on the
    security requirements enclosed within the <security requirements> tag. Follow the below guidelines when developing secure Terraform modules:     
            
            1. The attempt should be to develop secure Terraform modules for all the security requirements for the given AWS service.

            2. Use the "name" and "description" fields to develop understanding of the requirement for Terraform implementation.

            3. If there are any requirements that cannot be implemented in Terraform or can only be implemented partially, do so and maintain a note in the notes.md file.
                - Don't implement requirements for VPC endpoints like "Implement VPC Endpoints for Kinesis Data Streams" because VPC endpoints are managed outside of this module.
                - Don't implement requirements like "Enable AWS CloudTrail Logging for AppFlow API Calls" because CloudTrail logging has already been enabled for all accounts and all services.
                - Since IAM policies are use-case dependent, create 1 policy for read and 1 policy for write that users can OPTIONALLY use.
                - For the same resource, don't create multiple separate resource blocks. Instead, create 1 resource block with all the configurations. 
                    - For example:
                        - Instead of creating 2 different resources like "resource "aws_kms_key" "main"" and "resource "aws_kms_key" "tagged"", create only 1 "aws_kms_key" with all the configurations.
                        - Instead of creating 2 different resources like "resource "aws_apigatewayv2_stage" "xray"" and "resource "aws_apigatewayv2_stage" "main"", create only 1 "aws_apigatewayv2_stage" with all the configurations.

            4. DO NOT create supporting resources like s3 buckets, security groups, kms keys, cloudwatch log groups / alarms, etc. Assume that those have been created and the values will be provided.
                - For example: 
                    - When enabling access logs for ALB, assume that the s3 logs destination bucket is already created and value will be provided by user as input.
                    - When setting up security groups for resources (RDS, ECS, EKS, etc.), assume that the security group has already been created and value will be provided by user as input.
                    - When setting up encryption on a resource, assume that the KMS key has already been created and value will be provided by user as input.              
            
            5. Even when not specified explicitly, always implement security best practices like encryption at rest for all possible resources, latest TLS policies, disabling insecure defaults (e.g. disable_execute_api_endpoint = true for aws_api_gateway_rest_api), etc.
            
            6. Below are the 3 files that should be created:
                a. main.tf: Include all necessary resources and their configurations. Add comments for each requirement that was implemented in Terraform in the format ID:name directly above the actual configuration.
                b. variables.tf: Define all variables used in main.tf, including descriptions and default values where appropriate.
                    1. Set the default values to be the most secure values possible. E.g., set ALB to internal = true instead of default value of internal = false.
                c. notes.md: Provide a detailed breakdown in markdown syntax such that all requirements for the given AWS service are individually accounted for:
                    1. Requirements that were implemented in the Terraform code. Ensure you implement requirements in Terraform that are partially possible and maintain a note on that. 
                    2. Requirements that could be implemented but weren't included (if any) - this list should be as minimal as everything possible to implement through Terraform must be implemented.
                    3. Requirements that are inherently implemented by the implementation of a different requirement.
                    4. Requirements that cannot be directly implemented in Terraform along with an explanation.  
                    5. Any best practices or additional security measures not mentioned in the requirements but relevant to the AWS service.
                    6. Each of the requirements for the given AWS should be its own individual line, don't merge requirements like S3-001, S3-002, etc. in 1 row.
                    7. Example format for notes.md is provided below within the <notes.md example> tag.
            
            7. Review all the 3 files generated to make sure that they are accurate, align to the provided security requirements for the AWS service, and follow all the rules specified above.

            Ensure that the Terraform code is well-commented, follows best practices, and is as secure as possible. Include input variables for all configurable parameters to make the module reusable.

            Format your response exactly as below within the XML tags and do not include anything else:
            
            <main.tf>
            main.tf content
            </main.tf>
            
            <variables.tf>
            variables.tf content
            </variables.tf>

            <notes.md>
            notes.md content
            </notes.md>
    """

    user_prompt = """
    Below are the list of {num_service_requirement} for AWS {service_name} that need to be implemented in Terraform:
            
    <security requirements>
    {service_requirements}
    </security requirements>

    <notes.md example>
    {notes_format}
    </notes.md example>
    """.format(num_service_requirement=num_service_requirement, service_name=service_name, service_requirements=service_requirements, notes_format=notes_format)

    # Prepare the prompt for the Bedrock API call
    prompt = {    
        "system": sys_prompt,
        "messages": [  
            {  
                "role": "user",  
                "content": [  
                    {  
                        "type": "text",  
                        "text": user_prompt  
                    }  
                ]  
            }  
        ],    
        "max_tokens": 200000,    
        "anthropic_version": "bedrock-2023-05-31"    
    } 

    request = json.dumps(prompt)

    if USE_HF:
        combined_prompt = f"{sys_prompt}\n\n{user_prompt}"
        response_text = invoke_hf(combined_prompt)
    else:
        # Make the API call to Bedrock
        response = bedrock.invoke_model(
            modelId=model_id,
            body=request
        )

        # Parse and extract the response
        model_response = json.loads(response["body"].read())
        response_text = model_response["content"][0]["text"]
    return response_text

if __name__ == '__main__':
    # Directory containing security requirements for different services
    # This directory should contain subdirectories for each AWS service
    security_reqs_directory = "security-requirements/"

    # Process each service directory
    for service_name in os.listdir(security_reqs_directory):
        # Construct paths for the service requirements
        file_path = os.path.join(security_reqs_directory, service_name)
        file_path_ccr = file_path + "/security-reqs.json"
        
        # Read the security requirements for the current service
        service_requirements = read_json_file(file_path_ccr)
        num_service_requirement = len(service_requirements)  # Count of security requirements

        # Template format for the notes.md file
        # This provides an example structure for documenting implementation details
        notes_format = """
        # AWS S3 Bucket Security Requirements Implementation Notes

        1. S3-001: Block Public Access Settings enabled on Access Points
        - Implemented in Terraform code using `aws_s3_access_point` resource with public access block configuration.

        2. S3-002: Check if S3 buckets have a Lifecycle configuration enabled
        - Implemented in Terraform code using `aws_s3_bucket_lifecycle_configuration` resource.

        3. S3-003: Check if S3 buckets have server access logging enabled
        - Implemented in Terraform code within the `aws_s3_bucket` resource using the `logging` block.

        4. S3-004: Check if S3 buckets have object versioning enabled
        - Implemented in Terraform code within the `aws_s3_bucket` resource using the `versioning` block.

        5. S3-005: Check if S3 buckets have KMS encryption enabled
        - Implemented in Terraform code using `aws_s3_bucket_server_side_encryption_configuration` resource.

        6. S3-006: Ensure that general-purpose bucket policies restrict access to other AWS accounts
        - Not directly implemented in Terraform. This requires custom policy implementation based on specific use cases.

        7. S3-007: Check if S3 bucket MFA Delete is not enabled
        - Implemented in Terraform code by setting `mfa_delete = false` in the `versioning` block of `aws_s3_bucket` resource.

        8. S3-008: Ensure there are no S3 buckets writable by Everyone or Any AWS customer
        - Partially implemented through S3-017 (bucket-level public access block). Additional custom policies may be required.

        9. S3-009: Check if S3 buckets have ACLs enabled
        - Implemented in Terraform code by setting `acl = "private"` in the `aws_s3_bucket` resource.

        10. S3-010: Check if S3 buckets have policies which allow WRITE access
            - Not directly implemented in Terraform. Requires custom policy implementation based on specific use cases.

        11. S3-011: Ensure there are no S3 buckets open to Everyone or Any AWS user
            - Partially implemented through S3-017 (bucket-level public access block). Additional custom policies may be required.

        12. S3-012: Ensure there are no S3 buckets listable by Everyone or Any AWS customer
            - Partially implemented through S3-017 (bucket-level public access block). Additional custom policies may be required.

        13. S3-013: Check if S3 buckets use cross-region replication
            - Implemented in Terraform code using `aws_s3_bucket_replication_configuration` resource.

        14. S3-014: Check if S3 buckets have default encryption (SSE) enabled or use a bucket policy to enforce it
            - Implemented in Terraform code using `aws_s3_bucket_server_side_encryption_configuration` resource.

        15. S3-015: Check S3 Account Level Public Access Block
            - Implemented in Terraform code using `aws_s3_account_public_access_block` resource.

        16. S3-016: Check if S3 buckets have a secure transport policy
            - Implemented in Terraform code using `aws_s3_bucket_policy` resource to enforce HTTPS.

        17. S3-017: Check S3 Bucket Level Public Access Block
            - Implemented in Terraform code using `aws_s3_bucket_public_access_block` resource.

        18. S3-018: Check if S3 buckets have object lock enabled
            - Implemented in Terraform code by setting `object_lock_enabled = true` in the `aws_s3_bucket` resource.

        Additional security measures and best practices:
        - All configurable parameters are exposed as variables to make the module reusable and flexible.
        - The module uses the most secure options by default, such as enabling versioning, encryption, and public access blocks.
        - The module assumes that KMS keys and log buckets already exist and requires their IDs/ARNs as input.
        - Consider implementing additional access controls and monitoring for the S3 bucket and its associated resources.
        - Implement least privilege access principles when defining IAM policies for bucket access.
        - Regularly review and audit bucket policies and access logs to ensure compliance with security requirements.
        """

        # Generate the Terraform module content
        terraform_details = create_terraform_module(service_name, num_service_requirement, service_requirements, notes_format)
        print(terraform_details)

        # Regular expressions to extract different sections of the generated content
        patterns = {
            "main.tf": r"<main.tf>(.*?)</main.tf>",
            "variables.tf": r"<variables.tf>(.*?)</variables.tf>",
            "notes.md": r"<notes.md>(.*?)</notes.md>",
        }

        # Create directory for the service's Terraform files
        tf_directory_path = "aws-terraform/"+service_name
        os.makedirs(tf_directory_path, exist_ok=True)

        # Extract and write each file
        for file_name, pattern in patterns.items():
            match = re.search(pattern, terraform_details, re.DOTALL)
            if match:
                file_name = tf_directory_path + "/" + file_name
                content = match.group(1).strip()  # Extract matched content
                with open(file_name, "w") as file:
                    file.write(content)  # Write content to file
                print(f"File written: {file_name}")
            else:
                print(f"Pattern not found: {file_name}")