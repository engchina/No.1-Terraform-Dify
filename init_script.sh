#!/bin/bash
echo "Initializing application setup..."

cd /u01/aidify

# Move to source directory
cd /u01/aidify/No.1-Terraform-Dify

# Docker setup
chmod +x ./install_docker.sh
bash ./install_docker.sh
systemctl start docker

# Clone and install Dify
git clone -b 1.7.1 https://github.com/langgenius/dify.git
cd dify/docker

# Get OCI configuration from Terraform outputs
ORACLE_PASSWORD=$(cat /u01/aidify/props/adb_password.txt)
ORACLE_DSN=$(cat /u01/aidify/props/adb_dsn.txt)
ORACLE_WALLET_PASSWORD=$(cat /u01/aidify/props/wallet_password.txt)
BUCKET_NAMESPACE=$(cat /u01/aidify/props/bucket_namespace.txt)
BUCKET_NAME=$(cat /u01/aidify/props/bucket_name.txt)
BUCKET_REGION=$(cat /u01/aidify/props/bucket_region.txt)
OCI_ACCESS_KEY=$(cat /u01/aidify/props/oci_access_key.txt)
OCI_SECRET_KEY=$(cat /u01/aidify/props/oci_secret_key.txt)

cp .env.example .env
sed -i "s|EXPOSE_NGINX_PORT=80|EXPOSE_NGINX_PORT=8080|g" .env

# Configure Oracle ADB as Vector Store
sed -i "s|VECTOR_STORE=.*|VECTOR_STORE=oracle|g" .env
sed -i "s|ORACLE_USER=.*|ORACLE_USER=admin|g" .env
sed -i "s|ORACLE_PASSWORD=.*|ORACLE_PASSWORD=${ORACLE_PASSWORD}|g" .env
sed -i "s|ORACLE_DSN=.*|ORACLE_DSN=${ORACLE_DSN}|g" .env
sed -i "s|ORACLE_WALLET_PASSWORD=.*|ORACLE_WALLET_PASSWORD=${ORACLE_WALLET_PASSWORD}|g" .env
sed -i "s|ORACLE_IS_AUTONOMOUS=.*|ORACLE_IS_AUTONOMOUS=true|g" .env

# Modify docker-compose.yaml to skip Oracle container
sed -i "s|      - oracle|      - oracle-skip|g" docker-compose.yaml

# Configure OCI Object Storage
sed -i "s|STORAGE_TYPE=opendal|STORAGE_TYPE=oci-storage|g" .env

# Configure OCI Object Storage environment variables
OCI_ENDPOINT=https://${BUCKET_NAMESPACE}.compat.objectstorage.${BUCKET_REGION}.oraclecloud.com
OCI_BUCKET_NAME=${BUCKET_NAME}
OCI_REGION=${BUCKET_REGION}

# Apply OCI configuration to .env file
sed -i "s|OCI_ENDPOINT=.*|OCI_ENDPOINT=${OCI_ENDPOINT}|g" .env
sed -i "s|OCI_BUCKET_NAME=.*|OCI_BUCKET_NAME=${OCI_BUCKET_NAME}|g" .env
sed -i "s|OCI_ACCESS_KEY=.*|OCI_ACCESS_KEY=${OCI_ACCESS_KEY}|g" .env
sed -i "s|OCI_SECRET_KEY=.*|OCI_SECRET_KEY=${OCI_SECRET_KEY}|g" .env
sed -i "s|OCI_REGION=.*|OCI_REGION=${OCI_REGION}|g" .env

docker compose up -d

# Unzip wallet and copy essential file to instantclient
unzip /u01/aidify/props/wallet.zip -d /u01/aidify/props/wallet
# Copy wallet to Dify container
docker cp /u01/aidify/props/wallet docker-worker-1:/app/api/storage/wallet

# Application setup
EXTERNAL_IP=$(curl -s -m 10 http://whatismyip.akamai.com/)
echo "Dify is ready to use at http://${EXTERNAL_IP}:8080"

echo "Initialization complete."