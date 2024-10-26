import json
import os
from typing import List, Dict, Set
from pathlib import Path
import boto3
import re
from boto3 import client
from botocore.config import Config

# Configuration for the Bedrock client with an extended read timeout
config = Config(read_timeout=1000)

# Initialize the Bedrock client for AWS services
bedrock = boto3.client(service_name='bedrock-runtime', 
                       region_name='us-east-1',
                       config=config)

# Model ID to be used with the Bedrock API
model_id = "anthropic.claude-3-5-sonnet-20240620-v1:0"

class SecurityRequirementsConsolidator:
    """
    A class to consolidate security requirements from multiple sources (Prowler and Checkov)
    and enhance them using AWS Bedrock's Claude LLM.

    This class reads security requirements from specified directories, processes them using
    an LLM to improve quality and consistency, and saves the consolidated output.
    """

    def __init__(self, prowler_path: str, checkov_path: str, output_base_path: str):
        """
        Initialize the consolidator with paths to source and output directories.
        
        Args:
            prowler_path: Path to prowler-reqs directory containing security requirements
            checkov_path: Path to checkov directory containing security requirements
            output_base_path: Path where consolidated requirements will be saved
        """
        self.prowler_path = Path(prowler_path)
        self.checkov_path = Path(checkov_path)
        self.output_base_path = Path(output_base_path)
        
    def get_all_services(self) -> Dict[str, Set[str]]:
        """
        Find all services across both directories and their source locations.
        
        Scans both prowler and checkov directories to identify all unique services
        and tracks which source(s) contain requirements for each service.
        
        Returns:
            Dict with service names as keys and set of sources ('prowler', 'checkov') as values
        """
        # Collect directories from prowler and checkov paths
        prowler_services = {d.name for d in self.prowler_path.iterdir() if d.is_dir()}
        checkov_services = {d.name for d in self.checkov_path.iterdir() if d.is_dir()}
        
        # Create a dictionary to hold all services and their sources
        all_services = {}
        for service in prowler_services | checkov_services:  # Union of both sets
            sources = set()
            if service in prowler_services:
                sources.add('prowler')
            if service in checkov_services:
                sources.add('checkov')
            all_services[service] = sources
            
        return all_services
    
    def read_security_reqs(self, path: Path) -> Dict:
        """
        Read security requirements from a JSON file.

        Args:
            path: Path to the directory containing security-reqs.json

        Returns:
            Dict containing the security requirements, or empty dict if file not found
        """
        try:
            with open(path / "security-reqs.json") as f:
                return json.load(f)  # Load and return the JSON data
        except FileNotFoundError:
            return {}  # Return an empty dict if the file is not found
            
    def combine_requirements(self, service: str, sources: Set[str]) -> Dict:
        """
        Combine requirements from available sources for a given service.
        
        Args:
            service: Name of the AWS service
            sources: Set indicating which sources ('prowler', 'checkov') contain this service
        
        Returns:
            Combined list of requirements from all available sources
        """
        combined = []  # List to hold combined requirements
        
        # Combine requirements from Prowler source if available
        if 'prowler' in sources:
            prowler_reqs = self.read_security_reqs(self.prowler_path / service)
            if prowler_reqs:
                combined.extend(prowler_reqs)
        
        # Combine requirements from Checkov source if available
        if 'checkov' in sources:
            checkov_reqs = self.read_security_reqs(self.checkov_path / service)
            if checkov_reqs:
                combined.extend(checkov_reqs)
                
        return combined

    def format_requirements(self, requirements_str: str) -> List[Dict]:
        """
        Format and clean the requirements from LLM response.
        
        Processes the JSON string from the LLM, ensures consistent structure,
        and sorts requirements by ID.
        
        Args:
            requirements_str: JSON string from LLM
            
        Returns:
            List of formatted requirement dictionaries with consistent structure
        """
        try:
            # Clean up the input string
            requirements_str = requirements_str.strip()
            # Remove any markdown code block indicators if present
            requirements_str = re.sub(r'```json\s*|\s*```', '', requirements_str)
            
            # Parse the cleaned JSON string
            requirements = json.loads(requirements_str)
            
            # Ensure each requirement has consistent structure and order
            formatted_reqs = []
            for req in requirements:
                formatted_req = {
                    "ID": req.get("ID", ""),
                    "name": req.get("name", ""),
                    "description": req.get("description", ""),
                    "cloudProvider": req.get("cloudProvider", "AWS"),
                    "domain": req.get("domain", "")
                }
                formatted_reqs.append(formatted_req)
            
            # Sort the requirements by ID
            return sorted(formatted_reqs, key=lambda x: x["ID"])
            
        except json.JSONDecodeError as e:
            print(f"Error parsing requirements: {e}")  # Log any parsing errors
            return []  # Return an empty list in case of errors
        
    def review_with_llm(self, service_name: str, requirements: List[Dict], sources: Set[str], example_requirements: List[Dict]) -> List[Dict]:
        """
        Use LLM to review, deduplicate, and enhance requirements.
        
        Sends the requirements to Claude LLM for improvement, including deduplication,
        enhancement, and ensuring alignment with environment-specific setup.
        
        Args:
            service_name: Name of the AWS service
            requirements: Combined requirements to review
            sources: Set indicating which sources contain this service
            example_requirements: Example of well-written requirements for reference
        
        Returns:
            List of processed and enhanced requirements
        """
        # Prepare the system prompt for the LLM with guidelines
        sys_prompt = f"""You are a cloud security expert that is tasked with defining detailed technical security requirements AWS services. 
        The security requirements should be clear, well-worded, and descriptive with all the necessary details such that it can be easily understood and implemented by developers.
        
        Follow the below guidelines when developing technical security requirements:
        1. Below are the key details about my AWS environment's setup that needs to be adhered to always:
            - Network is setup to follow a hub and spoke architecture where the VPCs are connected to each other via Transit Gateways.
            - AWS management console access is federated through SSO via AWS Identity Center. IAM users are only created as an exception.  
            - AWS IAM user access keys are banned from use and instead IAM roles should be used.
            - CloudTrail management events have been enabled for all my AWS accounts for all services.
            - VPC flow logs have been enabled for all my VPCs for all AWS accounts. 
            - You can assume that all the resources are only private and have no requirement for any sort of public access.
            - Any resources that need to be publicly exposed to the internet, are managed separately and is outside the scope of the requirements defined here. 

        2. You will be provided security requirements enclosed within the <security requirements> tag for different AWS services as a starting point. 
            - If there are duplicative requirements on the same resource, combine them.
            - If the security violates / do not follow my environment's specific setup, remove them. 
            - if there are 2 requirements on the same resource for the same configuration, combine them into 1.
                - For example: If there are 2 requirements for encryption-at-rest on sagemaker notebook, combine them into 1.
            - If there are 2 requirements on 2 different resources for the same configuration, keep them separate. 
                - For example: If there is 1 requirement for encryption-at-rest on sagemaker notebook and another 1 for encryption-at-rest on sagemaker domain, keep them as separate.

        3. Add any missing security requirements for the given service and all of its resources to ensure a robust and comprehensive library of security requirements.          
           - Examples of security requirements that should be added if missing: use latest TLS policies, enforce HTTPS, disable public access, enable encryption at-rest using CMK, etc.

        4. When writing the "name" and "description", make it very clear and well-worded such that it is easy to understand and can be easily implemented by developers.
           - The "name" of the requirement should be a proper sentence and should be easy to understand. 
           - The "description" of the requirement should be detailed and should contain implementation details for that requirement. 
           - Pack all the details and context in the "name" and "description" of the requirement to make it easy to understand and implement for developers.
           - Don't abstract any details by using generic phrases like "apply secure settings". Instead, enumerate each setting that needs to be applied - "enabling TLS, enabling audit logging, enabling user activity logging, etc."  
           - Don't develop security requirements that are vague or generic.
           - The granularity / specificity of these security requirements should be such that it can be interpreted by developers and translated into IaC easily.

        5. When defining security requirements for the AWS service, only focus on requirements for that service. Don't define requirements for other services.
           - For example:
                - Avoid requirements like "Implement Regular Key Rotation for AppFlow KMS Keys" because this is captured in the requirements for AWS KMS by an overarching requirement like "Customer managed keys (CMK) should have rotation enabled for every 90 days".
                - Within AppFlow, we should only call out a requirement like "Use AWS KMS Customer Managed Key (CMK) for AppFlow Flow Encryption".

        6. Perform a detailed review on the developed security requirements to make sure the guidelines are followed and the below hold true:            
            - Requirements like "Enable AWS CloudTrail Logging for MSK Cluster API Calls" "Enable AWS CloudTrail Logging for AppFlow API Calls" don't exist because CloudTrail logs are already enabled for all services.
            - Requirements like ""Enable VPC Flow Logs for MWAA VPC" don't exist because VPC flow logs have been enabled for my VPCs. 
            - Requirements like "Implement Multi-Factor Authentication for Critical Route53 Changes" don't exist because federation / SSO through Identity Center enforces MFA.
            - Requirements with generic phrases like "restrict access" or "enforce principal of least privilege" don't exist. Instead, they are written more clearly like "restrict access to only known principals or accounts".
            - Vague requirements that are subject to interpretation don't exist.
                - For example: Requirements like "Ensure Proper Configuration of Elastic Load Balancer Listeners" and "Implement Secure Listener Rules for Application Load Balancers" don't exist. These are bad requirements because it is not clear how to implement this and is subject to interpretation by the developers. Instead, these requirements should be written where the exact configurations (HTTPS and latest TLS policies) are specified very clearly to ensure that all the necessary details are provided to implement secure load balancer listeners.       
            - Requirements are defined on all the different resources for the AWS service. 
                - For example: If there are requirements only for sagemaker domain but not sagemaker notebook, develop requirements for sagemaker notebook. Keep the requirements for sagemaker domain and sagemaker notebook separate, don't combine them.
            - Requirements where different types of configurations are combined don't exist. Instead, keep them as 2 separate requirements.
                - For example: "Enable encryption at rest and in transit for MSK Cluster" is a bad requirement. These should be split into 2 separate requirements like "Use KMS CMK for encryption-at-rest for MSK Cluster" and "Use latest TLS policies for encryption-in-transit for MSK Cluster".
            - Requirements where different types of resources are combined don't exist. Instead, keep them as 2 separate requirements. 
                - For example:
                    - "Use KMS CMK for encryption-at-rest for SageMaker Domain and Notebook Instance" is a bad requirement. These should be split into 2 separate requirements like "Use KMS CMK for encryption-at-rest for SageMaker Domain" and "Use KMS CMK for encryption-at-rest for SageMaker Notebook Instance"
                    - "Use Non-Default Ports for RDS Instances and Clusters" is a bad requirement. These should be split into 2 separate requirements like "Use Non-Default Ports for RDS Instances" and "Use Non-Default Ports for RDS Clusters"
        
        7. Update requirement IDs to follow format 'service:001', 'service:002', etc.
            - For example: s3:001; s3:002; s3:003, etc.
        
        8. Assign a "domain" to each requirement based on "name" and "description".
           - Possible values:
                - data protection
                - network security
                - identity and access management
                - logging and monitoring
                - secure configuration
       
        9. Ensure each requirement has these fields in this exact order:
           - ID (format: service:00X)
           - name (brief title)
           - description (detailed explanation)
           - cloudProvider (always "AWS")
           - domain

        Respond with ONLY a valid JSON array of requirements. Do not include any explanatory text or markdown formatting.
        """

        user_prompt = """
        Below is a list of requirements for AWS {service_name} that is to be used as a starting point:
        
        <security requirements>
        {requirements}
        </security requirements>

        Below is example of well-written security requirements for AWS S3 enclosed within the <example requirements> tag that can be used as reference when developing requirements for AWS {service_name}.

        <example requirements>
        {example_requirements}
        </example requirements>

        Respond with ONLY a valid JSON array of requirements. Do not include any explanatory text or markdown formatting.
        """.format(service_name=service_name, requirements=requirements, example_requirements=example_requirements)
        
        # Prepare the prompt for the LLM
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

        # Call Bedrock with the prompt to generate enhanced requirements
        response = bedrock.invoke_model(
            modelId=model_id,
            body=request
        )

        # Extract and format the model response
        model_response = json.loads(response["body"].read())
        response_text = model_response["content"][0]["text"]
        
        # Format and clean the requirements before returning
        return self.format_requirements(response_text)
            
    def save_consolidated_requirements(self, service: str, requirements: List[Dict]):
        """
        Save the consolidated requirements to the output directory.
        
        Args:
            service: Name of the AWS service
            requirements: List of processed requirements to save
        """
        # Prepare the output directory for the service
        output_dir = self.output_base_path / service
        output_dir.mkdir(parents=True, exist_ok=True)  # Create directory if it doesn't exist
        output_file = output_dir / "security-reqs.json"

        print(output_dir)  # Log the output directory path
        
        # Save the requirements to a JSON file
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(
                requirements,
                f,
                indent=2,  # Pretty print with indent
                ensure_ascii=False,
                sort_keys=False  # Preserve field order
            )
            f.write('\n')  # Add newline at end of file
            
    def process_all_services(self):
        """
        Process all services and consolidate their requirements.
        
        Main function that orchestrates the entire consolidation process:
        1. Identifies all services from both sources
        2. Combines requirements for each service
        3. Uses LLM to review and enhance requirements
        4. Saves the consolidated output
        """
        # Retrieve dictionary of all services with their source locations
        all_services = self.get_all_services()
        
        # Process each service and its associated sources
        for service, sources in all_services.items():
            # Log the current service being processed and its sources
            print(f"Processing {service} (found in: {', '.join(sources)})...")
            
            # Combine requirements from available sources for current service
            combined_reqs = self.combine_requirements(service, sources)

            # Define comprehensive example requirements for S3 service
            # This template includes security best practices across different domains
            # Each requirement has: ID, name, description, cloud provider, and domain
            example_requirements= [
                {
                    "ID": "s3:001",
                    "name": "Enable S3 Account-Level Public Access Block",
                    "description": "Ensure that the S3 Account-Level Public Access Block is enabled to prevent public access to all buckets in the account.",
                    "cloudProvider": "AWS",
                    "domain": "secure configuration"
                },
                {
                    "ID": "s3:002",
                    "name": "Enable S3 Bucket-Level Public Access Block",
                    "description": "Ensure that the S3 Bucket-Level Public Access Block is enabled for each individual bucket to prevent public access.",
                    "cloudProvider": "AWS",
                    "domain": "secure configuration"
                },
                {
                    "ID": "s3:003",
                    "name": "Enable Server-Side Encryption with AWS KMS for S3 Buckets",
                    "description": "Ensure that all S3 buckets have default encryption enabled using AWS Key Management Service (KMS) Customer Master Keys (CMKs).",
                    "cloudProvider": "AWS",
                    "domain": "data protection"
                },
                {
                    "ID": "s3:004",
                    "name": "Enable S3 Bucket Versioning",
                    "description": "Ensure that versioning is enabled for all S3 buckets to protect against accidental deletion or overwriting of objects.",
                    "cloudProvider": "AWS",
                    "domain": "data protection"
                },
                {
                    "ID": "s3:005",
                    "name": "Enable S3 Bucket Logging",
                    "description": "Ensure that server access logging is enabled for all S3 buckets to track requests for access to the bucket.",
                    "cloudProvider": "AWS",
                    "domain": "logging and monitoring"
                },
                {
                    "ID": "s3:006",
                    "name": "Implement S3 Bucket Lifecycle Policies",
                    "description": "Ensure that S3 buckets have appropriate lifecycle policies configured to manage object retention and transition between storage classes.",
                    "cloudProvider": "AWS",
                    "domain": "secure configuration"
                },
                {
                    "ID": "s3:007",
                    "name": "Enforce HTTPS for S3 Bucket Access",
                    "description": "Ensure that S3 bucket policies enforce the use of HTTPS (TLS) for all access to S3 buckets.",
                    "cloudProvider": "AWS",
                    "domain": "network security"
                },
                {
                    "ID": "s3:008",
                    "name": "Restrict S3 Bucket Access to Specific AWS Accounts",
                    "description": "Ensure that S3 bucket policies restrict access to only specified AWS accounts or IAM principals.",
                    "cloudProvider": "AWS",
                    "domain": "identity and access management"
                },
                {
                    "ID": "s3:009",
                    "name": "Enable S3 Object Lock",
                    "description": "Enable S3 Object Lock for critical buckets to prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely.",
                    "cloudProvider": "AWS",
                    "domain": "data protection"
                },
                {
                    "ID": "s3:010",
                    "name": "Implement Cross-Region Replication for Critical S3 Buckets",
                    "description": "Enable cross-region replication for critical S3 buckets to ensure data redundancy and availability across multiple AWS regions.",
                    "cloudProvider": "AWS",
                    "domain": "data protection"
                },
                {
                    "ID": "s3:011",
                    "name": "Disable S3 Bucket ACLs",
                    "description": "Disable Access Control Lists (ACLs) for S3 buckets and use bucket policies and IAM policies for access control instead.",
                    "cloudProvider": "AWS",
                    "domain": "identity and access management"
                },
                {
                    "ID": "s3:012",
                    "name": "Enable S3 Event Notifications",
                    "description": "Configure S3 event notifications to track and respond to important bucket and object-level operations.",
                    "cloudProvider": "AWS",
                    "domain": "logging and monitoring"
                },
                {
                    "ID": "s3:013",
                    "name": "Implement Least Privilege Access for S3 Buckets",
                    "description": "Ensure that IAM policies and S3 bucket policies follow the principle of least privilege, granting only the necessary permissions to authorized entities.",
                    "cloudProvider": "AWS",
                    "domain": "identity and access management"
                },
                {
                    "ID": "s3:014",
                    "name": "Enable MFA Delete for Versioned S3 Buckets",
                    "description": "Enable Multi-Factor Authentication (MFA) Delete for versioned S3 buckets to add an extra layer of security for deleting objects.",
                    "cloudProvider": "AWS",
                    "domain": "data protection"
                },
                {
                    "ID": "s3:015",
                    "name": "Implement S3 Access Points",
                    "description": "Use S3 Access Points to simplify managing access to shared datasets in S3 buckets with specific permissions for different applications or user groups.",
                    "cloudProvider": "AWS",
                    "domain": "identity and access management"
                }
            ]

            # Process the service if requirements were found
            if combined_reqs:
                # Use LLM to review and enhance the combined requirements using example template
                processed_reqs = self.review_with_llm(service, combined_reqs, sources, example_requirements)
                
                # Save the processed and consolidated requirements to output location
                self.save_consolidated_requirements(service, processed_reqs)
            else:
                # Log when no requirements are found for a service
                print(f"No requirements found for {service}")
                
            # Log completion of processing for current service
            print(f"Completed processing {service}")

def main():
    # Define input and output directory paths
    prowler_path = "prowler-rules"        # Directory containing Prowler requirements
    checkov_path = "checkov-rules"        # Directory containing Checkov requirements
    output_path  = "security-guardrails"  # Directory for storing consolidated output
    
    # Initialize the SecurityRequirementsConsolidator with specified paths
    consolidator = SecurityRequirementsConsolidator(
        prowler_path=prowler_path,
        checkov_path=checkov_path,
        output_base_path=output_path
    )
    
    # Execute the main processing workflow
    consolidator.process_all_services()

# Entry point of the script
if __name__ == "__main__":
    main()