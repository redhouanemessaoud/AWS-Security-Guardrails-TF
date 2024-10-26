import pandas as pd
import json
import os

# Load Excel file containing AWS rules into a DataFrame
df = pd.read_excel('checkov AWS rules.xlsx')

# Initialize ID counter for unique requirement IDs
id_counter = 1

# Group data by 'Service Name' column to process each service's requirements separately
for service, group in df.groupby('Service Name'):
    # Initialize a list to hold requirement dictionaries for the current service
    requirements = []
    
    # Reset ID counter for each service to ensure unique IDs
    id_counter = 1
    
    # Iterate over each row in the grouped DataFrame
    for index, row in group.iterrows():
        # Create a dictionary for the current requirement with necessary fields
        requirement = {
            "ID": f"{service.capitalize()}-{str(id_counter).zfill(3)}",  # Format ID as 'Service-###'
            "name": row['Name'],  # Extract requirement name from the current row
            "cloudProvider": "AWS",  # Specify the cloud provider
            "service name": service  # Include the service name
        }
        
        # Append the requirement dictionary to the requirements list
        requirements.append(requirement)
        
        # Increment the ID counter for the next requirement
        id_counter += 1

    # Define the output file path for the current service's requirements
    output_file = "checkov-rules/"+service+"/security-reqs.json"

    # Create the output directory structure if it doesn't already exist
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    # Write the list of requirements to the specified JSON output file with pretty formatting
    with open(output_file, 'w') as f:
        json.dump(requirements, f, indent=4)