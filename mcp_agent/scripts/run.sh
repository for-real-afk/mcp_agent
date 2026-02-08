#!/bin/bash

# Configuration
REPO_NAME="rahulpandey187/mcp-agent"
VERSION=${1:-latest}
CONTAINER_NAME="mcp-agent-server"

# Check for .env file
if [ ! -f .env ]; then
    echo "⚠️  No .env file found! Creating one from template..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Created .env from .env.example. Please add your API keys!"
    else
        echo "❌ Error: .env.example not found. Please create a .env file with GOOGLE_API_KEY."
        exit 1
    fi
fi

echo "🚀 Starting $REPO_NAME:$VERSION..."

# Stop and remove existing container if it exists
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# Pull latest image if version is latest
if [ "$VERSION" == "latest" ]; then
    echo "⬇️  Pulling latest image..."
    docker pull $REPO_NAME:$VERSION
fi

# Run the container
docker run -d \
    --name $CONTAINER_NAME \
    --env-file .env \
    -p 8001:8000 \
    --restart unless-stopped \
    $REPO_NAME:$VERSION

if [ $? -eq 0 ]; then
    echo "✅ MCP Agent is running at: http://localhost:8001"
    echo "📋 View logs with: docker logs -f $CONTAINER_NAME"
    echo "🏥 Health check: http://localhost:8001/health"
else
    echo "❌ Failed to start container!"
    exit 1
fi
