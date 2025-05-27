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
COPY ./Scripts /app/out/scripts
# Build database image
FROM mcr.microsoft.com/azure-sql-edge:latest AS database
ENV ACCEPT_EULA=Y
# Set the SA password at runtime using a secure method (e.g., Docker secrets or environment variable)
WORKDIR /app
COPY --from=build /app/out ./dbfiles
 
# Environment variables

# Expose port (change if your app uses a different port)
EXPOSE 1433
# Set environment variables if needed
# ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT [ "/opt/mssql/bin/sqlservr" ]