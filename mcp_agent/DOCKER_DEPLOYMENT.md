# Docker Deployment Guide for Alumnx MCP Agent

This guide explains how to manage Docker images and deployment for both contributors and maintainers.

## For Contributors (Quick Start)

If you just want to run the server without installing anything locally, follow these steps:

1.  **Clone the repository**:

    ```bash
    git clone <repo-url>
    cd mcp_agent
    ```

2.  **Set up environment variables**:
    Create a `.env` file in the root directory and add your API keys:

    ```env
    GOOGLE_API_KEY=your_key_here
    TAVILY_API_KEY=your_key_here
    LANGSMITH_API_KEY=your_key_here
    ```

3.  **Run with one command**:
    ```bash
    ./scripts/run.sh
    ```
    This script will automatically pull the latest image from Docker Hub and start the server.

Alternatively, you can use Docker Compose:

```bash
docker-compose up -d
```

---

## For Maintainers (Publishing)

To build and publish new images to Docker Hub:

### 1. Build the image

```bash
./scripts/build.sh [version]
```

Example: `./scripts/build.sh v1.0.0` or just `./scripts/build.sh` for `latest`.

### 2. Push to Docker Hub

Ensure you are logged in: `docker login`.

```bash
./scripts/push.sh [version]
```

---

## Technical Details

- **Docker Hub Repository**: `rahulpandey187/mcp-agent`
- **Internal Port**: 8000
- **External Port**: 8001
- **Health Check**: `http://localhost:8001/health`
- **Interactive Docs**: `http://localhost:8001/docs`

## Troubleshooting

- **Permissions**: If the scripts won't run, try `chmod +x scripts/*.sh`.
- **Docker Errors**: Ensure the Docker daemon is running.
- **API Keys**: Make sure your `.env` file is properly configured.
