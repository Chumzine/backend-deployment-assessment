#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/mongodb-setup.log) 2>&1

echo "Starting MongoDB server setup..."

# Retry yum commands when repositories temporarily fail.
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

# Configure the official MongoDB 7.0 repository.
echo "Configuring MongoDB repository..."

cat > /etc/yum.repos.d/mongodb-org-7.0.repo <<'EOF'
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

# Refresh package metadata.
echo "Refreshing package repositories..."
retry_yum yum clean all
retry_yum yum makecache

# Install MongoDB.
echo "Installing MongoDB..."
retry_yum yum install -y mongodb-org

# Allow connections from the private VPC network.
echo "Configuring MongoDB network access..."
sed -i 's/^  bindIp: 127.0.0.1/  bindIp: 0.0.0.0/' /etc/mongod.conf

# Enable and start MongoDB.
echo "Starting MongoDB service..."
systemctl enable mongod
systemctl start mongod

# Verify installation and service.
echo "Verifying MongoDB installation..."
mongod --version
systemctl status mongod --no-pager

echo "MongoDB server setup completed successfully."
