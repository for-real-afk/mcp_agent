# 🌾 Alumnx MCP Agent

An intelligent LangGraph-based agent that orchestrates multiple MCP (Model Context Protocol) servers to provide agricultural insights, weather data, and more.

## 🚀 Quick Start (One Command)

The entire platform is containerized for ease of use. To run the agent and all tools, simply run:

```bash
docker-compose up --build -d
```

This will:

1. Build the Agent image.
2. Start the FastAPI server on port **8001**.
3. Automatically discover all MCP tools.
4. Map your local directory for **Hot Reloading** (changes you make to code reflect immediately).

## 🛠️ Prerequisites

- **Docker & Docker Compose**: Installed and running.
- **Google AI API Key**: Get one from [Google AI Studio](https://aistudio.google.com/).

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
3. Verify with Docker: `docker-compose up --build`
4. Push and create a Pull Request.

## 🏗️ Architecture

- **FastAPI**: Main entry point and API layer.
- **LangGraph**: Orchestrates the agentic reasoning and tool-calling flow.
- **Gemini 2.5 Flash**: The LLM brain powering the agent.
- **MCP Servers**: Independent services providing specialized tools (found in `mcp_server.py` and `server/`).
