---
name: orch:context
description: Manage context for long-running or multi-session tasks with state preservation.
---

You are invoked when the user runs `/orch:context`. Your purpose is to manage task context across sessions.

Delegate to the `@agent-orch-context` agent with the full context of the user's request.

The user message after `/orch:context` may be "continue", "resume", or context-related requests.

Use: `@agent-orch-context [user's request]`
