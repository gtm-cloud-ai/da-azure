#!/bin/bash

# Start SQL Server in the background
/opt/mssql/bin/sqlservr &

# Store the PID of SQL Server
SQL_PID=$!

# Function to log events
log_event() {
    local event_name=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $event_name" >> /var/log/mssql/container-events.log
}

# Wait for SQL Server to be ready
sleep 10s
log_event "SQL Server Started"

# Monitor SQL Server process
while kill -0 $SQL_PID 2>/dev/null; do
    # Check SQL Server status
    if /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -Q "SELECT @@VERSION" &>/dev/null; then
        log_event "SQL Server Healthy"
    else
        log_event "SQL Server Issue Detected"
    fi
    sleep 60
done

# If SQL Server process dies, log it
log_event "SQL Server Stopped"
exit 1 