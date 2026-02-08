# 🌾 Alumnx MCP Agent

An intelligent LangGraph-based agent that orchestrates multiple MCP (Model Context Protocol) servers to provide agricultural insights, weather data, and more.

## 🚀 Quick Start (One Command)

The entire platform is containerized for ease of use. To run the agent without installing any packages locally:

1.  **Configure environment**: Create a `.env` file with your `GOOGLE_API_KEY`.
2.  **Run**:
    ```bash
    ./scripts/run.sh
    ```

This will:

1.  **Pull** the latest pre-built image from Docker Hub (`rahulpandey187/mcp-agent`).
2.  Start the FastAPI server on port **8001**.
3.  Automatically discover all MCP tools.

For development options and detailed Docker usage, see [DOCKER_DEPLOYMENT.md](./DOCKER_DEPLOYMENT.md).

## ⚙️ Configuration

1. Create a `.env` file in the root directory (you can use `.env.example` as a template).
2. Add your `GOOGLE_API_KEY`:
   ```env
   GOOGLE_API_KEY=your_key_here
   ```

## 📚 API Documentation

Once the container is running, access the interactive Swagger docs at:
👉 **[http://localhost:8001/docs](http://localhost:8001/docs)**

## 🧪 Testing

You can test the agent using `curl`:

```bash
curl -X POST "http://localhost:8001/chat" \
     -H "Content-Type: application/json" \
     -d '{"message": "What are the best seeds for organic wheat farming?"}'
```

## 🤝 Contributing

1. Create a new branch: `git checkout -b feature/your-feature-name`
2. Make your changes.
3. **Hot Reloading**: The container uses `--reload`, so changes to `.py` files are reflected instantly without needing to restart Docker!
4. **When to Rebuild**: If you add new libraries to `requirements.txt`, you **must** run:
   ```bash
   docker-compose up --build
   ```
5. Push and create a Pull Request.

## 🏗️ Architecture

- **FastAPI**: Main entry point and API layer.
- **LangGraph**: Orchestrates the agentic reasoning and tool-calling flow.
- **Gemini 2.5 Flash**: The LLM brain powering the agent.
- **MCP Servers**: Independent services providing specialized tools (found in `mcp_server.py` and `server/`).
