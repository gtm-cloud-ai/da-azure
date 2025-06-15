docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=mssql_2025' \
-p 1433:1433 \
-d local-saas-db:latest \
