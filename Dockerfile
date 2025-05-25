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
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/out ./

# Environment variables
ENV ASPNETCORE_URLS=http://+:80
ENV ConnectionStrings__DefaultConnection="Server=database;Database=SaaSDB;User Id=sa;Password=mssql_2025;TrustServerCertificate=True"

# Expose port (change if your app uses a different port)
EXPOSE 80

# Set environment variables if needed
# ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "DataAccess.dll"]