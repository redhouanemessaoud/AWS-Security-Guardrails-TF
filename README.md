# AWS Security Guardrails & Terraform

This repository contains a set of scripts designed to automate the generation of security requirements and secure Terraform modules for AWS services (supporting blog post can be found [here](https://naman16.github.io/cloud-security/AWS%20Security%20Guardrails%20%26%20Terraform/). The process is broken down into four main scripts, each with specific roles in parsing, consolidating, and implementing security rules for AWS environments.

## Workflow Overview

1. **checkov-requirements.py** - Parses and standardizes security requirements from Checkov.
2. **prowler-requirements.py** - Parses and standardizes security requirements from Prowler.
3. **requirements-generator.py** - Uses an LLM to consolidate and enhance security requirements.
4. **terraform-creator.py** - Generates reusable Terraform modules based on consolidated requirements or custom input.

---

## 1. checkov-requirements.py

- **Purpose**: This script extracts security requirements from Checkov, processes them, and outputs them in a standardized JSON format for each AWS service.
- **Input**: A manually created spreadsheet with Checkov rules. The spreadsheet was created by copying Checkov's requirements from [Checkov's Policy Index](https://www.checkov.io/5.Policy%20Index/terraform.html) into Excel, then editing to focus on commonly used AWS services.
- **Output**: A JSON file, `security-reqs.json`, for each AWS service under `checkov-rules/`.

**Process**:
1. The script reads the modified Checkov spreadsheet, which contains requirements relevant to specific AWS services.
2. For each service, a `security-reqs.json` file is created, containing the standardized security requirements.

---

## 2. prowler-requirements.py

- **Purpose**: This script collects and organizes security requirements from Prowler. After cloning the [Prowler repository](https://github.com/prowler-cloud/prowler), some services were excluded to keep the focus on commonly used services.
- **Input**: Security rules from the Prowler repository.
- **Output**: A JSON file, `security-reqs.json`, for each AWS service under `prowler-rules/`.

**Process**:
1. The script iterates through Prowler's service-specific folders and collects security rules.
2. For each service, a `security-reqs.json` file is generated in a standardized format for easy integration in later steps.

---

## 3. requirements-generator.py

- **Purpose**: This script processes and consolidates requirements from Checkov and Prowler with the help of **Anthropic's Claude 3.5 Sonnet model**. The LLM enhances the initial requirements and structures them in a unified format.
- **Input**: JSON files generated from `checkov-requirements.py` and `prowler-requirements.py`.
- **Output**: Consolidated JSON files under `security-requirements/` for each service, e.g., `s3/security-reqs.json`, `glue/security-reqs.json`, etc.

### LLM Prompt Details

The **LLM prompt** is customized for **AWS environments** with an emphasis on **multi-account setups**. It directs the model to generate requirements that accommodate common practices in multi-account AWS configurations, like account isolation and cross-account permissions. 

While designed for AWS, the prompt can be adapted for other cloud providers like **Azure** by changing the cloud-specific terminology. The prompt uses **Checkov** and **Prowler** as baseline sources but incorporates the LLM's AWS knowledge to enhance and add context to the requirements. 

#### Extensibility

This setup is flexible and can be expanded by:
- **Adding Sources**: Incorporate additional tools or rules by updating the LLM prompt.
- **Switching Cloud Providers**: Modify the prompt to work with other providers, like Azure or GCP.
- **Adjusting Requirements Style**: Tailor the requirements to specific security configurations or to match internal policies by adjusting the input JSON files and prompt instructions.

---

## 4. terraform-creator.py

- **Purpose**: This script generates **Terraform modules** for each AWS service based on the consolidated security requirements, focusing on reusability. The generated modules provide a modular approach, allowing users to use components like **S3 buckets** and **KMS keys** consistently across multiple configurations by passing required values.
- **Input**: Consolidated JSON files from `requirements-generator.py` or custom requirements JSON files formatted as specified.
- **Output**: A directory for each AWS service under `aws-terraform/`, containing:
  - `main.tf`: Contains Terraform resources and configurations.
  - `variables.tf`: Defines input variables for each module.
  - `notes.md`: Documents implementation details and security considerations.

### Custom Requirements Option

If you already have security requirements or policies defined, you can skip the Checkov and Prowler steps and provide your own JSON files directly to `terraform-creator.py`. Ensure your custom JSON files follow the same standardized format used by the `requirements-generator.py` output, and place them in the `security-requirements/` directory. This allows you to leverage this automation solely for Terraform generation without modifying or generating new requirements.

### LLM Prompt Details

The **LLM prompt** emphasizes **modular and reusable code**. For example, the prompt ensures that resources such as **S3 buckets** and **KMS keys** are implemented as standalone modules, which can be reused across configurations by simply passing relevant values. This approach ensures consistency and simplifies maintenance.

#### Extensibility

This prompt can be adjusted to accommodate different Terraform creation styles:
- **Reusability vs. Inline Configuration**: Generate fully modular code or in-line configurations depending on the team’s needs.
- **Adding Cloud Providers**: Adapt the prompt to output Terraform for Azure or GCP by switching the terminology.
- **Additional Security Configurations**: Adjust the LLM prompt to implement custom organizational policies, naming conventions, or tagging requirements.

---
