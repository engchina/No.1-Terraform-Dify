#!/bin/bash
echo "Initializing application setup..."

cd /u01/aidify

# Unzip wallet and copy essential file to instantclient
unzip /u01/aidify/props/wallet.zip -d ./wallet

# Move to source directory
cd /u01/aidify/No.1-Terraform-Dify

dos2unix main.cron
crontab main.cron

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
cd ../..
docker compose up -d

# Application setup
EXTERNAL_IP=$(curl -s -m 10 http://whatismyip.akamai.com/)
#sed -i "s|localhost:3000|$EXTERNAL_IP:3000|g" ./langfuse/docker-compose.yml
#chmod +x ./langfuse/main.sh
#nohup ./langfuse/main.sh &

echo "Initialization complete."