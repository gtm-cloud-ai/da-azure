# Use the official .NET SDK image for building the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set environment for ARM64
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

WORKDIR /app

# Install EF Core tools with specific path
ENV PATH="/root/.dotnet/tools:${PATH}"
RUN dotnet tool install --global dotnet-ef --version 8.0.0

# Copy and restore project
COPY *.csproj ./
RUN dotnet restore

# Generate SQL scripts
COPY . ./
RUN dotnet ef migrations script -o sql/install.sql

# Final stage with Azure SQL Edge (ARM64 compatible)
FROM mcr.microsoft.com/azure-sql-edge:latest

# SQL Server configuration
ENV ACCEPT_EULA=Y
ENV MSSQL_PID=Developer

WORKDIR /app

# Copy SQL installation script and entrypoint
COPY --from=build /app/sql/install.sql /app/sql/
COPY --chmod=777 entrypoint.sh /app/

# Expose SQL Server port
EXPOSE 1433

# Health check adjusted for Azure SQL Edge
HEALTHCHECK --interval=30s --timeout=3s \
    CMD /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -Q "SELECT 1" || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]