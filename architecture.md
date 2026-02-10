# 🏗️ System Architecture

## Overview

This system uses a **Dynamic LangGraph ReAct Agent** that automatically discovers and orchestrates tools from multiple MCP servers. No hardcoding required - add a tool to any MCP server and the agent can use it immediately.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER/CLIENT                             │
│              (Browser, cURL, Mobile App)                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ HTTP POST /chat
                           │ {"message": "User query"}
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FASTAPI APPLICATION                          │
│                      (agents.py)                                │
│                                                                  │
│  • Receives HTTP requests                                       │
│  • Validates input with Pydantic                                │
│  • Routes to DynamicMCPAgent                                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   DYNAMIC MCP AGENT                             │
│                 (DynamicMCPAgent class)                         │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         LangGraph ReAct Agent                            │  │
│  │                                                           │  │
│  │  1. Receives user query                                  │  │
│  │  2. Thinks about which tool(s) to use                    │  │
│  │  3. Executes tool(s)                                     │  │
│  │  4. Observes results                                     │  │
│  │  5. Reasons about next steps                             │  │
│  │  6. Repeats 2-5 until done                               │  │
│  │  7. Generates final answer                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│                  Uses ▼                                         │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Gemini 2.0 Flash (LLM)                           │  │
│  │  • Reasoning engine                                       │  │
│  │  • Tool selection logic                                   │  │
│  │  • Natural language understanding                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│                  Uses ▼                                         │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         MCPToolWrapper                                    │  │
│  │  • Discovers all tools from all MCP servers               │  │
│  │  • Wraps MCP tools as LangChain tools                     │  │
│  │  • Provides unified interface                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ Communicates with
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      MCP MANAGER                                │
│                   (MCPManager class)                            │
│                                                                  │
│  • Loads config.json                                            │
│  • Manages multiple MCP clients                                 │
│  • Routes tool calls to correct server                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ Manages
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     MCP CLIENTS                                 │
│                   (MCPClient instances)                         │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Client 1   │  │   Client 2   │  │   Client N   │         │
│  │              │  │              │  │              │         │
│  │ agricultural │  │   weather    │  │  database    │         │
│  │   -server    │  │   -server    │  │   -server    │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                  │                  │                 │
│         │ stdio (JSON-RPC) │                  │                 │
│         ▼                  ▼                  ▼                 │
└─────────────────────────────────────────────────────────────────┘
         │                  │                  │
         ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                      MCP SERVERS                                │
│                (Subprocess Python scripts)                      │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  Server 1    │  │  Server 2    │  │  Server N    │         │
│  │              │  │              │  │              │         │
│  │ Tools:       │  │ Tools:       │  │ Tools:       │         │
│  │ • weather    │  │ • database   │  │ • files      │         │
│  │ • pesticide  │  │ • analytics  │  │ • search     │         │
│  │ • posts      │  │              │  │              │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │                  │                  │
          │ Calls External APIs                 │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                            │
│                                                                  │
│  • wttr.in (Weather API)                                        │
│  • jsonplaceholder.typicode.com (Mock Posts API)                │
│  • Your custom databases, APIs, etc.                            │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. FastAPI Application
- **File**: `agents.py`
- **Purpose**: HTTP server exposing REST API
- **Tech**: FastAPI, Uvicorn
- **Responsibilities**:
  - Handle HTTP requests/responses
  - Input validation
  - Route to agent
  - Return formatted results

### 2. DynamicMCPAgent
- **Class**: `DynamicMCPAgent`
- **Purpose**: Orchestrates tool discovery and execution
- **Components**:
  - **LangGraph ReAct Agent**: Reasoning loop
  - **Gemini LLM**: Decision making
  - **MCPToolWrapper**: Tool management
- **Responsibilities**:
  - Initialize LLM
  - Discover tools from MCP servers
  - Create ReAct agent with discovered tools
  - Process user queries
  - Return final answers

### 3. LangGraph ReAct Agent
- **Type**: Built-in LangGraph agent
- **Pattern**: ReAct (Reasoning + Acting)
- **Cycle**:
  ```
  Thought → Action → Observation → Thought → ...
  ```
- **Features**:
  - Multi-step reasoning
  - Tool chaining
  - Self-correction
  - Context retention

### 4. MCPToolWrapper
- **Class**: `MCPToolWrapper`
- **Purpose**: Bridge between MCP and LangChain
- **Responsibilities**:
  - Connect to all MCP servers
  - Discover available tools
  - Convert MCP tools to LangChain `StructuredTool`
  - Map tool calls to correct server

### 5. MCPManager
- **Class**: `MCPManager`
- **Purpose**: Manage multiple MCP server connections
- **Responsibilities**:
  - Load `config.json`
  - Create `MCPClient` for each server
  - Provide unified access to all servers

### 6. MCPClient
- **Class**: `MCPClient`
- **Purpose**: Interface to single MCP server
- **Protocol**: JSON-RPC over stdio
- **Responsibilities**:
  - Spawn MCP server subprocess
  - Communicate via stdin/stdout
  - List available tools
  - Execute tool calls

### 7. MCP Servers
- **Type**: Standalone Python scripts
- **Protocol**: MCP (Model Context Protocol)
- **Communication**: stdio (stdin/stdout)
- **Responsibilities**:
  - Register tools
  - Execute tool logic
  - Return formatted results

## Key Design Decisions

### 1. Dynamic Tool Discovery
**Why**: No hardcoding means adding tools is trivial
**How**: At startup, connect to all servers and wrap all tools

### 2. LangGraph ReAct Agent
**Why**: Built-in reasoning, multi-step capabilities
**How**: Use `create_react_agent` with discovered tools

### 3. MCP Protocol
**Why**: Standard, secure, language-agnostic
**How**: JSON-RPC over stdio for local-only communication

### 4. Multi-Server Architecture
**Why**: Separation of concerns, independent tool domains
**How**: Each server manages its own tools, all available to agent

### 5. LangChain StructuredTool Wrapper
**Why**: Makes MCP tools compatible with LangGraph
**How**: Dynamically generate LangChain tools from MCP tool schemas

## Data Models

### AgentState (LangGraph)
```python
{
  "messages": [
    HumanMessage("User query"),
    AIMessage("Thinking..."),
    ToolMessage("Tool result"),
    AIMessage("Final answer")
  ]
}
```

### MCP Tool Definition
```json
{
  "name": "get_weather",
  "description": "Get weather for a city",
  "inputSchema": {
    "type": "object",
    "properties": {
      "city": {"type": "string"}
    },
    "required": ["city"]
  }
}
```



### LangChain StructuredTool
```python
StructuredTool(
  name="get_weather",
  description="Get weather for a city",
  func=async_function,
  args_schema=DynamicModel
)
```

## Scaling Considerations

### Horizontal Scaling
- Multiple FastAPI instances behind load balancer
- Each instance manages its own MCP connections
- Stateless design allows easy replication

### Tool Isolation
- Each MCP server runs independently
- Failures isolated to single server
- Easy to restart/replace individual servers

### Performance
- Async/await throughout for concurrency
- Lazy MCP connection (connect when needed)
- LLM calls are the bottleneck (not MCP)

## Security

### Current
- ✅ Local-only MCP communication (stdio)
- ✅ No network exposure of MCP servers
- ❌ No API authentication
- ❌ No rate limiting

### Production Recommendations
- Add API key authentication
- Implement rate limiting
- Add request validation
- Monitor for abuse
- Use secrets manager for API keys

## Extensibility

### Adding New Tools
1. Add to existing MCP server
2. Create new MCP server
3. Restart agent - tools auto-discovered

### Adding New MCP Servers
1. Create server file
2. Add to `config.json`
3. Restart agent

### Changing LLM
```python
# In agents.py
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4")
```

### Custom Tool Logic
Override `_create_langchain_tool` in `MCPToolWrapper` to add:
- Input validation
- Output formatting
- Error handling
- Logging
- Caching

## Monitoring

### Health Checks
- `/health` endpoint
- Monitor:
  - Agent initialization status
  - LLM connectivity
  - MCP server count
  - Tools loaded

### Logging
- Startup logs show tool discovery
- Each query logs intermediate steps
- Tool calls logged to stderr

### Metrics to Track
- Request count
- Response time
- Tool usage frequency
- Error rate
- LLM token usage