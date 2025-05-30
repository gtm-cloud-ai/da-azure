# Use the official .NET SDK image for building the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Install EF Core tools
RUN dotnet tool install --global dotnet-ef
ENV PATH="${PATH}:/root/.dotnet/tools"

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy necessary files for DB migration
COPY . ./
RUN dotnet ef migrations script -o sql/install.sql

# Build database image
FROM mcr.microsoft.com/mssql/rhel/server:latest

# SQL Server configuration
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=mssql_2025
ENV MSSQL_PID=Developer

WORKDIR /app

# Copy SQL installation script and entrypoint
COPY --from=build /app/sql/install.sql /app/sql/
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# Expose SQL Server port
EXPOSE 1433

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -Q "SELECT 1" || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]