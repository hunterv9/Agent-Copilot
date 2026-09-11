# Multi-Stack Copilot & Agent Instructions

This repository contains multi-stack projects (**React + Node.js**, **Python FastAPI**, and **PHP**). All AI agents must follow these guidelines to ensure fast, token-efficient, and accurate execution.

---

## 1. Stack Detection Rules (Detect First, Don't Guess)

Always inspect workspace manifests on Turn 1 before running commands or generating code:
- **Node.js / React**: Look for `package.json`
- **Python FastAPI**: Look for `pyproject.toml`, `requirements.txt`, or `main.py`
- **PHP**: Look for `composer.json`

---

## 2. Standard Commands Per Stack

### 🟢 Node.js / React
- **Install**: `npm install` (or `pnpm install` / `yarn`)
- **Build**: `npm run build`
- **Lint**: `npm run lint`
- **Test**: `npm test`

### 🟡 Python FastAPI
- **Install**: `pip install -r requirements.txt` (or `poetry install`)
- **Run Dev**: `uvicorn main:app --reload`
- **Test**: `pytest`
- **Lint**: `ruff check .` / `flake8`

### 🔵 PHP
- **Install**: `composer install`
- **Test**: `./vendor/bin/phpunit` or `php artisan test`
- **Lint**: `./vendor/bin/phpstan analyse` / `./vendor/bin/phpcs`

---

## 3. General Agent Execution Guardrails

1. **Path-Scoped Execution**:
   - NEVER search or scan the entire repository blindly.
   - Always scope `search`/`grep` calls to targeted directories (e.g., `src/`, `app/`, `frontend/`, `backend/`).

2. **Action-First Protocol**:
   - Call tools (`read`, `search`, `edit`, `execute`) immediately on Turn 1.
   - DO NOT write lengthy conversational intro text before making tool calls.

3. **Lean Routing (No Agent Bloat)**:
   - **Small fixes (XS/S)**: Execute direct tool calls (`view`/`edit`). Do NOT invoke sub-agents.
   - **Bug fixes / Features (M)**: Use `Dev` $\rightarrow$ `Test`.
   - **Complex Re-architecture (L/XL)**: Use `Architect` or `Team Lead`.

4. **Output Brevity**:
   - Max 300 tokens per agent response.
   - Concise Vietnamese bullets for summaries.
   - Code evidence as `path/to/file.ext:line`.
