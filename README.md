# 🚀 Dynamic LangGraph MCP Agent

A production-ready agent system that automatically discovers and uses tools from MCP (Model Context Protocol) servers using LangGraph's ReAct architecture.

## ✨ Features

- **🤖 LangGraph ReAct Agent** - Built-in reasoning and multi-step planning
- **🔍 Automatic Tool Discovery** - No hardcoding, just add MCP servers and go
- **🧠 LLM-Powered Routing** - Gemini Flash intelligently selects the right tools
- **🔌 Multi-Server Support** - Connect to unlimited MCP servers
- **📝 Multi-Step Reasoning** - Agent can chain multiple tools to solve complex tasks
- **✨ Zero Configuration** - Add tools and they work instantly

## 📁 Project Structure

```
mcp-agent/
├── agents.py              # Main application (FastAPI + LangGraph)
├── mcp_server.py          # MCP server with agricultural tools
├── config.json            # MCP server configuration
├── .env                   # Environment variables (API keys)
├── requirements.txt       # Python dependencies
├── README.md              # This file
├── ARCHITECTURE.md        # System architecture documentation
└── DATAFLOW.md           # Complete data flow explanation
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Set Up Environment Variables

Create a `.env` file:

```env
GOOGLE_API_KEY=your_google_api_key_here
```

Get your API key from: https://aistudio.google.com/app/apikey

### 3. Configure MCP Servers

Edit `config.json` with your MCP server paths:

```json
{
  "mcpServers": {
    "agricultural-server": {
      "command": "python",
      "args": ["mcp_server.py"],
      "env": {
        "PYTHONIOENCODING": "utf-8"
      }
    }
  }
}
```

**Important:** Use full paths on Windows:
```json
{
  "command": "D:\\Python\\python.exe",
  "args": ["D:\\projects\\mcp-agent\\mcp_server.py"]
}
```

### 4. Start the Server

```bash
python agents.py
```

### 5. Test the Agent

Visit http://localhost:8000/docs

Or use cURL:

```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "What is the weather in Tokyo?"}'
```

## 📊 Available Tools

| Tool | Description | Arguments |
|------|-------------|-----------|
| `get_current_weather` | Real-time weather data | city (string) |
| `get_pesticide_seed_info` | Agricultural information | query (string) |
| `get_placeholder_posts` | Sample blog posts | limit (integer) |

## 🧪 Example Queries

```bash
# Weather query → Uses get_current_weather
"What's the weather in Paris?"

# Agriculture query → Uses get_pesticide_seed_info  
"Tell me about organic farming techniques"

# Content query → Uses get_placeholder_posts
"Show me 5 interesting articles"

# Multi-step reasoning → Uses multiple tools
"What's the weather in Mumbai and what crops grow best there?"
```

## 🔧 API Endpoints

### `POST /chat`
Main endpoint for chatting with the agent

**Request:**
```json
{
  "message": "Your query here"
}
```

**Response:**
```json
{
  "response": "Agent's answer",
  "intermediate_steps": ["Tool used: get_current_weather"],
  "error": null
}
```

### `GET /` - Server info
### `GET /tools` - List all tools
### `GET /health` - Health check

## 🔌 Adding New Tools

Edit `mcp_server.py`:

```python
@mcp_server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        # ... existing tools ...
        Tool(
            name="my_new_tool",
            description="What this tool does",
            inputSchema={
                "type": "object",
                "properties": {
                    "param": {"type": "string"}
                },
                "required": ["param"]
            }
        )
    ]
```

Restart the agent - tools are auto-discovered!

## 🐛 Troubleshooting

**"GOOGLE_API_KEY not found"**
- Create `.env` file with your API key

**"No MCP servers found"**
- Check `config.json` exists and has correct paths

**"Agent not initialized"**
- Verify MCP server starts independently: `python mcp_server.py`

## 📚 Resources

- **LangGraph**: https://langchain-ai.github.io/langgraph/
- **MCP Protocol**: https://modelcontextprotocol.io
- **Gemini API**: https://ai.google.dev/

See [ARCHITECTURE.md](architecture.md) for system design.
See [DATAFLOW.md](DATAFLOW.md) for data flow details.
