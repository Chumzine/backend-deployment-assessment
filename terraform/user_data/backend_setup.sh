#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/backend-setup.log) 2>&1

echo "Starting backend server setup..."

# Retry yum commands in case of temporary repository timeouts.
retry_yum() {
    local attempt=1
    local max_attempts=5

    until "$@"; do
        if [ "$attempt" -ge "$max_attempts" ]; then
            echo "Command failed after $max_attempts attempts: $*"
            return 1
        fi

        echo "Attempt $attempt failed. Retrying in 15 seconds..."
        sleep 15
        attempt=$((attempt + 1))
    done
}

# Refresh package metadata and update installed packages.
echo "Updating Amazon Linux packages..."
retry_yum yum clean metadata
retry_yum yum makecache
retry_yum yum update -y

# Install Docker.
echo "Installing Docker..."
amazon-linux-extras install docker -y

# Install supporting utilities.
echo "Installing supporting packages..."
retry_yum yum install -y git curl

# Enable and start Docker.
echo "Starting Docker service..."
systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker commands.
usermod -aG docker ec2-user

# Install Docker Compose v2 as a Docker CLI plugin.
echo "Installing Docker Compose..."

mkdir -p /usr/local/lib/docker/cli-plugins

curl -fSL --retry 5 --retry-delay 5 \
    https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64 \
    -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Create the legacy docker-compose command as well.
ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

# Verify installations.
echo "Verifying Docker..."
docker --version

echo "Verifying Docker Compose..."
docker compose version

echo "Backend server setup completed successfully."
