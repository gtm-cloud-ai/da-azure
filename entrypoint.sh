#!/bin/bash
set -e

# Start SQL Server
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to start..."
for i in {1..60}; do
    if /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $MSSQL_SA_PASSWORD -Q "SELECT 1" &>/dev/null; then
        echo "SQL Server is up and running"
        break
    fi
    sleep 1
done

# Run the installation script
echo "Running database installation script..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -d master -i /app/sql/install.sql

# Keep container running
tail -f /dev/null