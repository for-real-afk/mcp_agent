# 🌾 Alumnx MCP Agent

---

### 🚀 Deploy the Entire platform in **Seconds**

Welcome to the **Alumnx MCP Agent** repository. This project is built for high-performance agricultural intelligence, using **LangGraph**, **Gemini 2.5 Flash**, and **Model Context Protocol (MCP)**.

---

## ⚡ Quick Start (One Command)

To run the entire platform—including the Intelligent Agent and all connected MCP servers—run this from the root of the `mcp_agent` folder:

```bash
docker-compose up --build -d
```

> [!TIP]
> Use `-d` to run in detached mode. If you want to see the agent reasoning live, omit the `-d` or run `docker-compose logs -f`.

---

## 🛠️ Developer Onboarding

### 1. Prerequisites

- **Docker Engine** (e.g., Docker Desktop)
- **Google AI API Key** — [Get it here](https://aistudio.google.com/)

### 2. Environment Setup

Copy the example environment file and add your key:

```bash
cp .env.example .env
# Open .env and set GOOGLE_API_KEY
```

### 3. Verification

Access the live API documentation here once the container is running:
👉 **[http://localhost:8001/docs](http://localhost:8001/docs)**

---

## 🏗️ Technical Stack

- **Brain**: [Gemini 2.5 Flash](https://blog.google/technology/ai/google-gemini-next-generation-model-february-2024/) (Optimized for 2026 Free Tier)
- **Orchestration**: [LangGraph](https://python.langchain.com/docs/langgraph/) (ReAct Agent Pattern)
- **Protocol**: [MCP](https://modelcontextprotocol.io/) (Weather & Agri-Intelligence servers)
- **Backend Framework**: FastAPI (Asynchronous Python)
- **Continuous Environment**: Docker & Docker Compose

---

## 🤝 Contribution Guidelines

We love external contributions! To get started:

1.  **Branching**: Always create a feature branch (`git checkout -b feature/xyz`).
2.  **Standards**: Follow PEP8 for Python and ensure `docker-compose up` passes without errors.
3.  **Hot Reloading**: While in development, the container mounts your local directory. Any changes you save will be instantly reflected in the running container!

---

## 📡 Sample Query

```bash
curl -X POST "http://localhost:8001/chat" \
     -H "Content-Type: application/json" \
     -d '{"message": "What is the status of wheat pesticides in 2026?"}'
```

---

_Built with ❤️ for the future of agriculture._
