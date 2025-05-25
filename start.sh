docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=mssql_2025' \
-p 1433:1433 \
-v /Users/fthornton/_dev/SAAS_GTM/Commercial-Marketplace-SaaS-Accelerator/src/DataAccess/stg/data:/var/opt/mssql/data \
-v /Users/fthornton/_dev/SAAS_GTM/Commercial-Marketplace-SaaS-Accelerator/src/DataAccess/stg/log:/var/opt/mssql/log \
-v /Users/fthornton/_dev/SAAS_GTM/Commercial-Marketplace-SaaS-Accelerator/src/DataAccess/stg/secrets:/var/opt/mssql/secrets \
-d docker.io/fthornton67/gtm-cloud:db \
--name gtm-cloud \
