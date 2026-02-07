# Alumnx MCP Agent Platform

Welcome to the Alumnx MCP Agent repository! This platform provides a dynamic ReAct agent powered by LangGraph and MCP (Model Context Protocol).

## 🚀 Quick Start

To run the entire platform with a single command, ensure you have Docker and Docker Compose installed, then run:

```bash
docker-compose up -d
```

The API will be available at: **http://localhost:8001**
Documentation (Swagger UI): **http://localhost:8001/docs**

## 🛠️ Components

- **MCP Agent**: The core intelligence layer (FastAPI + LangGraph).
- **Agricultural Server**: MCP server for agricultural data.
- **Weather Server**: MCP server for weather data via wttr.in.

## 📝 Setup

1. **Environment Variables**:
   Copy `.env.example` to `.env` inside the `mcp_agent` directory and fill in your API keys:
   - `GOOGLE_API_KEY`: Get one from Google AI Studio.
   - `TAVILY_API_KEY`: (Optional) For web search capabilities.
   - `LANGSMITH_API_KEY`: (Optional) For tracing.

2. **Development**:
   The containers use volume mounts, so changes you make to the code will reflect instantly inside the container!

## 🤝 Contributing

1. Create a new branch: `git checkout -b feature/your-feature-name`
2. Commit your changes: `git commit -m "Add some feature"`
3. Push to the branch: `git push origin feature/your-feature-name`
4. Open a Pull Request!
