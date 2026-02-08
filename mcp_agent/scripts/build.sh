#!/bin/bash

# Configuration
REPO_NAME="rahulpandey187/mcp-agent"
VERSION=${1:-latest}

echo "🚀 Building Docker image: $REPO_NAME:$VERSION..."

# Build the image
docker build -t $REPO_NAME:$VERSION .

if [ $? -eq 0 ]; then
    echo "✅ Successfully built $REPO_NAME:$VERSION"
else
    echo "❌ Build failed!"
    exit 1
fi
