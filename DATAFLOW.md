# 🔄 Complete Data Flow

This document traces a complete request through the entire system, from HTTP request to final response.

## Example Query

**User asks:** "What's the weather in Tokyo?"

## Timeline

```
0ms     User sends HTTP request
5ms     FastAPI receives and validates
10ms    Agent begins processing
15ms    LLM analyzes query
200ms   LLM decides to use get_current_weather tool
205ms   MCPClient spawns MCP server (if not running)
350ms   MCP server fully started
355ms   Tool call sent to MCP server
360ms   MCP server calls wttr.in API
1200ms  Weather API responds
1205ms  MCP server formats response
1210ms  Result sent back to agent
1215ms  LLM formulates final answer
1400ms  Response sent to user
```

## Detailed Step-by-Step Flow

### Step 1: HTTP Request (0ms)

**User action:**
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "What is the weather in Tokyo?"}'
```

**Network:**
```
POST /chat HTTP/1.1
Host: localhost:8000
Content-Type: application/json

{"message": "What is the weather in Tokyo?"}
```

---

### Step 2: FastAPI Receives Request (5ms)

**Location:** `agents.py` → `@app.post("/chat")`

**Code execution:**
```python
@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    # 1. Pydantic validates JSON
    # request.message = "What is the weather in Tokyo?"
    
    # 2. Check agent is initialized
    if not dynamic_agent:
        raise HTTPException(status_code=503, ...)
    
    # 3. Call agent
    result = await dynamic_agent.run(request.message)
    
    # 4. Return response
    return ChatResponse(**result)
```

**State:**
```python
request = ChatRequest(message="What is the weather in Tokyo?")
```

---

### Step 3: Agent Receives Query (10ms)

**Location:** `DynamicMCPAgent.run()`

**Code execution:**
```python
async def run(self, user_message: str) -> Dict[str, Any]:
    print(f"💬 User Query: {user_message}")
    
    # Create input for ReAct agent
    inputs = {"messages": [HumanMessage(content=user_message)]}
    
    # Run the agent (this is where magic happens!)
    result = await self.agent_executor.ainvoke(inputs)
    
    # Extract answer
    final_answer = result["messages"][-1].content
    
    return {
        "response": final_answer,
        "intermediate_steps": [...]
    }
```

**State:**
```python
inputs = {
    "messages": [
        HumanMessage(content="What is the weather in Tokyo?")
    ]
}
```

---

### Step 4: LangGraph ReAct Agent Begins (15ms)

**LangGraph Internal:**

The ReAct agent follows this pattern:

```
┌─────────────┐
│  THOUGHT    │  "I need to check the weather in Tokyo"
└─────┬───────┘
      │
      ▼
┌─────────────┐
│   ACTION    │  Call get_current_weather(city="Tokyo")
└─────┬───────┘
      │
      ▼
┌─────────────┐
│ OBSERVATION │  "Weather in Tokyo: 18°C, Partly cloudy..."
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  THOUGHT    │  "I have the weather information"
└─────┬───────┘
      │
      ▼
┌─────────────┐
│   ANSWER    │  "The weather in Tokyo is..."
└─────────────┘
```

---

### Step 5: LLM Analyzes Query (15ms - 200ms)

**LLM Call #1: Understanding & Planning**

**Prompt sent to Gemini:**
```
You are a helpful assistant with access to the following tools:

Tool: get_current_weather
Description: Get current weather conditions for a specific city or location. 
Use this when users ask about weather, temperature, or climate.
Arguments: city (string)

Tool: get_pesticide_seed_info
Description: Get information about pesticides and seeds for agricultural purposes.
Arguments: query (string)

Tool: get_placeholder_posts
Description: Fetch mock blog posts from JSONPlaceholder API.
Arguments: limit (integer)

User message: What is the weather in Tokyo?

Think step by step about what to do.
```

**LLM Response:**
```json
{
  "thought": "The user is asking about weather in Tokyo. I should use the get_current_weather tool.",
  "action": "get_current_weather",
  "action_input": {
    "city": "Tokyo"
  }
}
```

---

### Step 6: Tool Call Routed (205ms)

**Location:** `MCPToolWrapper._create_langchain_tool()`

**The wrapper function executes:**
```python
async def mcp_tool_function(**kwargs) -> str:
    """Dynamically generated function"""
    # kwargs = {"city": "Tokyo"}
    
    # Find which server has this tool
    server_name = self.tool_to_server["get_current_weather"]
    # server_name = "agricultural-server"
    
    # Get the client
    client = self.mcp_manager.clients[server_name]
    
    # Connect and call
    async with client.connect():
        result = await client.call_tool("get_current_weather", kwargs)
        return result
```

---

### Step 7: MCP Client Connects (205ms - 350ms)

**Location:** `MCPClient.connect()`

**Code execution:**
```python
@asynccontextmanager
async def connect(self):
    # Create server parameters
    server_params = StdioServerParameters(
        command="python",
        args=["mcp_server.py"],
        env={...}
    )
    
    # Spawn subprocess
    # Equivalent to: python mcp_server.py
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # Initialize connection
            await session.initialize()
            
            # Handshake:
            # Client → Server: {"method": "initialize"}
            # Server → Client: {"result": "initialized"}
            
            yield self
```

**Process spawned:**
```bash
$ python mcp_server.py
# Server starts, listens on stdin, ready to receive JSON-RPC
```

---

### Step 8: Tool Call Sent to MCP Server (355ms)

**Protocol:** JSON-RPC over stdin

**Message sent:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "get_current_weather",
    "arguments": {
      "city": "Tokyo"
    }
  }
}
```

**Location:** MCP server receives via `stdin`

---

### Step 9: MCP Server Executes Tool (360ms)

**Location:** `mcp_server.py` → `@mcp_server.call_tool()`

**Code execution:**
```python
@mcp_server.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    
    if name == "get_current_weather":
        city = arguments.get("city")  # "Tokyo"
        
        # Call external weather API
        data = await fetch_weather_data(city)
        
        # Format response
        current = data["current_condition"][0]
        formatted = (
            f"🌤️  Current Weather in {city}:\n"
            f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            f"Temperature: {current['temp_C']}°C\n"
            f"Condition: {current['weatherDesc'][0]['value']}\n"
            f"Humidity: {current['humidity']}%\n"
            f"Wind Speed: {current['windspeedKmph']} km/h"
        )
        
        return [TextContent(type="text", text=formatted)]
```

---

### Step 10: External API Call (360ms - 1200ms)

**Location:** `fetch_weather_data()`

**HTTP request:**
```python
async def fetch_weather_data(city: str) -> dict:
    async with httpx.AsyncClient() as client:
        url = f"https://wttr.in/{city}?format=j1"
        response = await client.get(url)
        # Waits ~800ms for API response
        return response.json()
```

**External API response:**
```json
{
  "current_condition": [{
    "temp_C": "18",
    "weatherDesc": [{"value": "Partly cloudy"}],
    "humidity": "65",
    "windspeedKmph": "15"
  }],
  ...
}
```

---

### Step 11: MCP Server Returns Result (1205ms)

**Message sent to stdout:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [{
      "type": "text",
      "text": "🌤️  Current Weather in Tokyo:\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nTemperature: 18°C\nCondition: Partly cloudy\nHumidity: 65%\nWind Speed: 15 km/h"
    }]
  }
}
```

---

### Step 12: MCP Client Receives Result (1210ms)

**Location:** `MCPClient.call_tool()`

**Code execution:**
```python
async def call_tool(self, tool_name: str, arguments: Dict[str, Any]) -> str:
    # Send request (already done)
    result = await self.session.call_tool(tool_name, arguments)
    
    # Extract text
    if result.content:
        text = "\n".join([
            item.text for item in result.content 
            if hasattr(item, 'text')
        ])
        return text
    
    # text = "🌤️  Current Weather in Tokyo:..."
```

**Returns to:** `mcp_tool_function` wrapper

**Returns to:** LangGraph agent

---

### Step 13: Agent Observes Result (1215ms)

**LangGraph internal state:**
```python
{
  "messages": [
    HumanMessage("What is the weather in Tokyo?"),
    AIMessage("I'll check the weather using get_current_weather"),
    ToolMessage("🌤️  Current Weather in Tokyo:..."),  # ← New
  ]
}
```

---

### Step 14: LLM Formulates Final Answer (1215ms - 1400ms)

**LLM Call #2: Final Response**

**Prompt sent to Gemini:**
```
You are a helpful assistant.

Previous conversation:
User: What is the weather in Tokyo?
Assistant: I'll check the weather using get_current_weather
Tool result: 🌤️  Current Weather in Tokyo:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Temperature: 18°C
Condition: Partly cloudy
Humidity: 65%
Wind Speed: 15 km/h

Now provide a final answer to the user.
```

**LLM Response:**
```
The current weather in Tokyo is partly cloudy with a temperature of 18°C. 
The humidity is at 65% and there's a gentle wind of 15 km/h. It's a pleasant day!
```

---

### Step 15: Agent Returns to FastAPI (1400ms)

**Location:** `DynamicMCPAgent.run()` returns

**Return value:**
```python
{
  "response": "The current weather in Tokyo is partly cloudy with a temperature of 18°C. The humidity is at 65% and there's a gentle wind of 15 km/h. It's a pleasant day!",
  "intermediate_steps": [
    "Tool used: get_current_weather"
  ],
  "error": None
}
```

---

### Step 16: FastAPI Sends HTTP Response (1400ms)

**Location:** `chat_endpoint` returns

**HTTP response:**
```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "response": "The current weather in Tokyo is partly cloudy with a temperature of 18°C. The humidity is at 65% and there's a gentle wind of 15 km/h. It's a pleasant day!",
  "intermediate_steps": [
    "Tool used: get_current_weather"
  ],
  "error": null
}
```

---

### Step 17: User Receives Response (1400ms)

**User's terminal:**
```json
{
  "response": "The current weather in Tokyo is partly cloudy with a temperature of 18°C. The humidity is at 65% and there's a gentle wind of 15 km/h. It's a pleasant day!",
  "intermediate_steps": ["Tool used: get_current_weather"],
  "error": null
}
```

## Summary Diagram

```
User Request
     │
     ▼
┌─────────────────┐
│    FastAPI      │  Validates input
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Dynamic Agent   │  Receives query
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ LangGraph       │  Thought: Need weather data
│ ReAct Agent     │  Action: get_current_weather
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ MCP Tool        │  Routes to agricultural-server
│ Wrapper         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ MCP Client      │  Spawns server, sends JSON-RPC
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ MCP Server      │  Executes get_current_weather
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ wttr.in API     │  Returns weather data
└────────┬────────┘
         │
         ▼ (all the way back up)
User receives final answer
```

## Data Transformations

### 1. HTTP JSON → Pydantic Model
```python
# Input
{"message": "What is the weather in Tokyo?"}

# Becomes
ChatRequest(message="What is the weather in Tokyo?")
```

### 2. String → HumanMessage
```python
# Input
"What is the weather in Tokyo?"

# Becomes
HumanMessage(content="What is the weather in Tokyo?")
```

### 3. MCP Tool Schema → LangChain Tool
```python
# MCP format
{
  "name": "get_current_weather",
  "inputSchema": {"properties": {"city": {"type": "string"}}}
}

# Becomes LangChain StructuredTool
StructuredTool(
  name="get_current_weather",
  func=async_function,
  args_schema=DynamicPydanticModel
)
```

### 4. Tool Call → JSON-RPC
```python
# LangChain call
tool.invoke(city="Tokyo")

# Becomes JSON-RPC
{
  "method": "tools/call",
  "params": {
    "name": "get_current_weather",
    "arguments": {"city": "Tokyo"}
  }
}
```

### 5. MCP Response → String
```python
# MCP format
{
  "content": [{
    "type": "text",
    "text": "🌤️  Current Weather..."
  }]
}

# Extracted to
"🌤️  Current Weather in Tokyo:..."
```

### 6. Agent Result → HTTP Response
```python
# Agent returns
{
  "response": "The current weather...",
  "intermediate_steps": [...]
}

# FastAPI serializes to JSON
{
  "response": "...",
  "intermediate_steps": [...],
  "error": null
}
```

## Error Handling Flow

### Example: Weather API fails

```
User → FastAPI → Agent → Tool Wrapper → MCP Client → MCP Server
                                                          │
                                          wttr.in API ✗ FAILS
                                                          │
MCP Server catches exception ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←┘
     │
     ├→ Returns error TextContent
     │
MCP Client receives ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←┘
     │
     ├→ Returns error string
     │
Agent observes error ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←┘
     │
     ├→ LLM sees error, generates user-friendly message
     │
FastAPI receives ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←┘
     │
     ├→ Returns 200 OK with error message in response
     │
User receives: "Sorry, I couldn't fetch the weather data right now."
```

## Multi-Tool Example

**Query:** "What's the weather in Mumbai and what crops grow best there?"

```
1. LLM decides: Need TWO tools
   
2. Call get_current_weather(city="Mumbai")
   Result: "Weather in Mumbai: 32°C, Humid..."
   
3. LLM observes weather result
   
4. LLM decides: Now call get_pesticide_seed_info
   
5. Call get_pesticide_seed_info(query="crops for Mumbai climate")
   Result: "For hot, humid climates like Mumbai..."
   
6. LLM observes both results
   
7. LLM synthesizes: "Mumbai is 32°C and humid. For this climate, 
   I recommend crops like rice, mangoes, and coconuts..."
```

## Performance Bottlenecks

1. **LLM API Calls** (~150-300ms each)
   - Solution: Use streaming responses
   
2. **MCP Server Startup** (~100-200ms first call)
   - Solution: Keep servers warm
   
3. **External APIs** (~500-1000ms)
   - Solution: Cache responses
   
4. **Multiple Tool Calls** (cumulative)
   - Solution: Parallel tool execution where possible

## State Management

The system is **stateless** between requests:
- No conversation memory
- Each request is independent
- MCP connections are ephemeral

For **stateful** conversations, add:
- Conversation history storage
- Session management
- Context retention across messages
