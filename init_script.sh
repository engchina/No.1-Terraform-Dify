#!/bin/bash
echo "Initializing application setup..."

cd /u01/aidify

# Move to source directory
cd /u01/aidify/No.1-Terraform-Dify

# Update environment variables
DB_CONNECTION_STRING=$(cat /u01/aidify/props/db.env)
COMPARTMENT_ID=$(cat /u01/aidify/props/compartment_id.txt)
cp .env.example .env
DB_CONNECTION_STRING=$(cat /u01/aidify/props/db.env)
sed -i "s|ORACLE_23AI_CONNECTION_STRING=TODO|ORACLE_23AI_CONNECTION_STRING=$DB_CONNECTION_STRING|g" .env
COMPARTMENT_ID=$(cat /u01/aidify/props/compartment_id.txt)
sed -i "s|OCI_COMPARTMENT_OCID=TODO|OCI_COMPARTMENT_OCID=$COMPARTMENT_ID|g" .env

# Docker setup
chmod +x ./install_docker.sh
bash ./install_docker.sh
systemctl start docker

# Clone and install Dify
git clone -b 1.7.1 https://github.com/langgenius/dify.git
cd dify/docker
cp .env.example .env
sed -i "s|EXPOSE_NGINX_PORT=80|EXPOSE_NGINX_PORT=8080|g" .env

# Configure Oracle ADB as Vector Store
sed -i "s|VECTOR_STORE=weaviate|VECTOR_STORE=oracle|g" .env
sed -i "s|ORACLE_USER=dify|ORACLE_USER=admin|g" .env
sed -i "s|ORACLE_PASSWORD=dify|ORACLE_PASSWORD=$(cat /u01/aidify/props/db_password.txt)|g" .env
sed -i "s|ORACLE_DSN=oracle:1521/FREEPDB1|ORACLE_DSN=$(cat /u01/aidify/props/db_dsn.txt)|g" .env
sed -i "s|ORACLE_WALLET_PASSWORD=dify|ORACLE_WALLET_PASSWORD=$(cat /u01/aidify/props/wallet_password.txt)|g" .env
sed -i "s|ORACLE_IS_AUTONOMOUS=false|ORACLE_IS_AUTONOMOUS=true|g" .env

# Modify docker-compose.yaml to skip Oracle container
sed -i "s|      - oracle|      - oracle-skip|g" docker-compose.yaml

# Configure OCI Object Storage
#sed -i "s|# STORAGE_TYPE=opendal|STORAGE_TYPE=oci-storage|g" .env
#echo "" >> .env
#echo "# Oracle Storage Configuration" >> .env
#echo "#" >> .env
#echo "OCI_ENDPOINT=https://<OBJECT_STORAGE_NAMESPACE>.compat.objectstorage.<OCI_REGION>.oraclecloud.com" >> .env
#echo "OCI_BUCKET_NAME=<BUCKET_NAME>" >> .env
#echo "OCI_ACCESS_KEY=<ACCESS_KEY>" >> .env
#echo "OCI_SECRET_KEY=<SECRET_KEY>" >> .env
#echo "OCI_REGION=<OCI_REGION>" >> .env

docker compose up -d

# Unzip wallet and copy essential file to instantclient
unzip /u01/aidify/props/wallet.zip -d /u01/aidify/props/wallet
# Copy wallet to Dify container
docker cp /u01/aidify/props/wallet docker-worker-1:/app/api/storage/wallet

# Application setup
EXTERNAL_IP=$(curl -s -m 10 http://whatismyip.akamai.com/)
#sed -i "s|localhost:3000|$EXTERNAL_IP:3000|g" ./langfuse/docker-compose.yml
#chmod +x ./langfuse/main.sh
#nohup ./langfuse/main.sh &

echo "Initialization complete."