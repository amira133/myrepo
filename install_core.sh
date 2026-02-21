#!/bin/bash
set -e

FILE_URL="https://raw.githubusercontent.com/amira133/myrepo/blob/main/temp2.zip"
INSTALL_DIR="/opt/core"
ARCHIVE="/tmp/core.zip"

echo "Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
fi

echo "Checking unzip..."
if ! command -v unzip &> /dev/null; then
    sudo apt update
    sudo apt install -y unzip
fi

echo "Creating directory..."
sudo mkdir -p $INSTALL_DIR

echo "Downloading archive..."
curl -L $FILE_URL -o $ARCHIVE

# گرفتن پسورد
if [ -z "$1" ]; then
    read -s -p "Enter archive password: " ZIP_PASSWORD
    echo ""
else
    ZIP_PASSWORD="$1"
fi

echo "Extracting..."
sudo unzip -o -P "$ZIP_PASSWORD" $ARCHIVE -d $INSTALL_DIR

echo "Removing old container if exists..."
sudo docker rm -f core 2>/dev/null || true

echo "Starting container..."
sudo docker run -d \
  --restart=always \
  --name core \
  --privileged \
  -v /opt/core/config:/core/config \
  -v /opt/core/data:/core/data \
  -p 8080:8080 \
  -p 8181:8181 \
  -p 1935:1935 \
  -p 1936:1936 \
  -p 6000:6000/udp \
  docker.arvancloud.ir/datarhei/restreamer:latest

echo "Done ✅"