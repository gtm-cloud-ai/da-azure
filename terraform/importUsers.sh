#!/bin/bash

# Configuration
KEYCLOAK_URL="http://localhost:8081"
REALM="master"
CLIENT_ID="admin-cli"
USERNAME="admin"
PASSWORD="admin123"

# Get access token
echo "Getting access token..."
ACCESS_TOKEN=$(curl -s -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=${CLIENT_ID}" \
    -d "username=${USERNAME}" \
    -d "password=${PASSWORD}" \
    -d "grant_type=password" \
    | jq -r '.access_token')

# Read users from JSON and create them
echo "Creating users..."
jq -c '.[]' users.json | while read -r user; do
    echo "Creating user: $(echo $user | jq -r '.username')"
    curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM}/users" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "${user}"
    sleep 1  # Rate limiting
done

echo "User import completed!"
