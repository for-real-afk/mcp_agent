#!/bin/bash

# Configuration
REPO_NAME="rahulpandey187/mcp-agent"
VERSION=${1:-latest}

echo "🚢 Pushing Docker image $REPO_NAME:$VERSION to Docker Hub..."

# Push the image
docker push $REPO_NAME:$VERSION

if [ $? -eq 0 ]; then
    echo "✅ Successfully pushed $REPO_NAME:$VERSION"
else
    echo "❌ Push failed! Are you logged in to Docker Hub? (Run 'docker login')"
    exit 1
fi
