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
RUN dotnet ef migrations script > /app/out/install.sql

# Build database image
FROM mcr.microsoft.com/mssql/rhel/server:latest
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=mssql_2025
ENV MSSQL_PID=Developer
WORKDIR /app
COPY --from=build /app/out ./dbfiles

# Environment variables
ENV ASPNETCORE_URLS=http://+:80
ENV ConnectionStrings__DefaultConnection="Server=database;Database=SaaSDB;User Id=sa;Password=mssql_2025;TrustServerCertificate=True"
RUN /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P mssql_2025 -i /app/scripts/create-database.sql
RUN /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P mssql_2025 -i /app/dbfiles/install.sql
# Expose port (change if your app uses a different port)
EXPOSE 1433
# Set environment variables if needed
# ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT [ "/opt/mssql/bin/sqlservr" ]