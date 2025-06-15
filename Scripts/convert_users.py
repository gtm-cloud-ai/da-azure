import pandas as pd
import json
import sys

def convert_excel_to_json(excel_file):
    # Read Excel file
    df = pd.read_excel(excel_file)
    
    # Convert to Keycloak user format
    users = []
    for _, row in df.iterrows():
        user = {
            "username": row['username'],
            "enabled": True,
            "emailVerified": True,
            "firstName": row['firstName'],
            "lastName": row['lastName'],
            "email": row['email'],
            "credentials": [{
                "type": "password",
                "value": "Test123!",
                "temporary": True
            }],
            "groups": row['groups'].split(',') if 'groups' in row else []
        }
        users.append(user)
    
    # Write to JSON file
    with open('users.json', 'w') as f:
        json.dump(users, f, indent=2)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python convert_users.py <excel_file>")
        sys.exit(1)
    convert_excel_to_json(sys.argv[1])