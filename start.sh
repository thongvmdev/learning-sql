#!/bin/bash

# MySQL Docker Setup Script
# This script helps you set up and start MySQL using Docker Compose

set -e

echo "==================================="
echo "MySQL Docker Setup"
echo "==================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    echo ""
    echo "Creating .env file from template..."
    cat > .env << 'EOF'
# MySQL Root Password (required)
MYSQL_ROOT_PASSWORD=MySecureRootPass123!

# Database name to create on startup
MYSQL_DATABASE=learning_db

# Application user credentials
MYSQL_USER=dev_user
MYSQL_PASSWORD=DevUserPass123!
EOF
    echo "✅ .env file created with default values"
    echo ""
    echo "⚠️  IMPORTANT: Please update the passwords in .env file before using in production!"
    echo ""
fi

# Start Docker Compose
echo "Starting MySQL container..."
docker compose up -d

echo ""
echo "Waiting for MySQL to be ready..."
sleep 5

# Check if container is running
if docker compose ps | grep -q "Up"; then
    echo ""
    echo "==================================="
    echo "✅ MySQL is up and running!"
    echo "==================================="
    echo ""
    echo "Connection Details:"
    echo "-------------------"
    echo "Host:     localhost"
    echo "Port:     3306"
    echo "Database: learning_db"
    echo "User:     dev_user"
    echo "Password: DevUserPass123!"
    echo ""
    echo "Useful Commands:"
    echo "-------------------"
    echo "View logs:        docker compose logs -f mysql"
    echo "Connect to MySQL: docker compose exec mysql mysql -u dev_user -p"
    echo "Stop MySQL:       docker compose down"
    echo "Check status:     docker compose ps"
    echo ""
else
    echo ""
    echo "❌ MySQL container failed to start. Check logs with:"
    echo "   docker compose logs mysql"
    exit 1
fi
