import json
import os

# Initialize a counter for unique requirement IDs
id_counter = 1

# Define the root directory containing AWS service directories
root_dir = 'prowler/prowler/providers/aws/services'

# Iterate over each subdirectory in the 'services' directory
for service in os.listdir(root_dir):
    # Reset ID counter for each service
    id_counter = 1
    security_reqs = []  # Initialize list to hold security requirements

    # Skip files, only process directories representing services
    if os.path.isdir(os.path.join(root_dir, service)):
        requirements_path = os.path.join(root_dir, service)

        # Iterate over requirements directories within the service directory
        for requirement in os.listdir(requirements_path):
            # Skip files and process only requirement directories
            if requirement != 'lib' and os.path.isdir(os.path.join(requirements_path, requirement)):
                # Define the path to the metadata file for the current requirement
                metadata_file = os.path.join(requirements_path, requirement, f'{requirement}.metadata.json')

                # Open and load the metadata file into a dictionary
                with open(metadata_file, 'r') as f:
                    metadata = json.load(f)
                
                # Extract required fields from the metadata
                service_name = metadata['ServiceName']
                check_title = metadata['CheckTitle']
                description = metadata['Description']

                # Append a dictionary with requirement details to the list
                security_reqs.append({
                    'ID': f"{service_name.capitalize()}-{str(id_counter).zfill(3)}",  # Format ID as 'Service-###'
                    'name': check_title,  # Title of the check from metadata
                    'description': description,  # Description of the check from metadata
                    'cloudProvider': 'AWS',  # Specify the cloud provider
                    'service name': service_name,  # Include the service name
                })
                
                # Increment the ID counter for the next requirement
                id_counter += 1
        
        # Define the output file path for the current service's security requirements
        output_file = "prowler-reqs/"+service+"/security-reqs.json"

        # Create the output directory structure if it doesn't already exist
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        
        # Write the list of security requirements to the specified JSON output file with pretty formatting
        with open(output_file, 'w') as f:
            json.dump(security_reqs, f, indent=4)