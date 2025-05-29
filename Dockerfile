# Use the official .NET SDK image for building the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Install EF Core tools
RUN dotnet tool install --global dotnet-ef
ENV PATH="${PATH}:/root/.dotnet/tools"

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the source code
COPY . ./
RUN dotnet publish -c Release -o out

# Build database image
FROM mcr.microsoft.com/mssql/rhel/server:latest
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=mssql_2025
ENV MSSQL_PID=Developer
WORKDIR /app
COPY --from=build /app/out ./

# Environment variables
ENV ASPNETCORE_URLS=http://+:80
ENV ConnectionStrings__DefaultConnection="Server=database;Database=SaaSDB;User Id=sa;Password=mssql_2025;TrustServerCertificate=True"

# Expose port (change if your app uses a different port)
EXPOSE 1433
# Set environment variables if needed
# ENV ASPNETCORE_ENVIRONMENT=Production

# Copy the event logging script
COPY docker-entrypoint-events.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-events.sh

# Create log directory
RUN mkdir -p /var/log/mssql && \
    chown mssql:mssql /var/log/mssql

# Change entrypoint to our script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-events.sh"]

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
    CMD /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -Q "SELECT 1" || exit 1