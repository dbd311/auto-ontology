#!/bin/bash

# =============================================
# INSTALL APACHE JENA ON UBUNTU 20.04 LTS
# =============================================

# Exit immediately if any command fails
set -e

# Step 1: Install Java (OpenJDK)
echo "[1/5] Installing Java (OpenJDK 17)..."
sudo apt update -qq
sudo apt install -y openjdk-17-jdk

# Verify Java installation
if ! java -version &> /dev/null; then
    echo "❌ Java installation failed. Exiting."
    exit 1
fi

# Step 2: Download Apache Jena (Latest Stable)
JENA_VERSION="5.3.0"  # Update to latest if needed
JENA_URL="https://dlcdn.apache.org/jena/binaries/apache-jena-$JENA_VERSION.tar.gz"
JENA_DIR="/opt/jena"

echo "[2/5] Downloading Apache Jena $JENA_VERSION..."
wget -q $JENA_URL -O apache-jena.tar.gz

# Step 3: Extract and Install Jena
echo "[3/5] Extracting and installing Jena..."
sudo rm -rf $JENA_DIR
sudo mkdir -p $JENA_DIR
sudo tar -xzf apache-jena.tar.gz -C /tmp/

sudo mv /tmp/apache-jena-$JENA_VERSION/* $JENA_DIR

# Step 4: Set Environment Variables
echo "[4/5] Setting up environment variables..."
echo "export JENA_HOME=$JENA_DIR" >> ~/.bashrc
echo "export PATH=\$PATH:\$JENA_HOME/bin" >> ~/.bashrc
source ~/.bashrc

# Step 5: Verify Installation
echo "[5/5] Verifying installation..."
if ! sparql --version &> /dev/null; then
    echo "❌ Jena installation failed. Check logs."
    exit 1
else
    echo "✅ Apache Jena installed successfully!"
    echo "Run 'sparql --version' to verify."
fi

# Cleanup
rm -f apache-jena.tar.gz