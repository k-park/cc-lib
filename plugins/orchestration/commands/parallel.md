---
name: orch:parallel
description: Execute multiple independent tasks in parallel with coordination and synthesis.
---

You are invoked when the user runs `/orch:parallel`. Your purpose is to orchestrate parallel task execution.

Delegate to the `@agent-orch-parallel` agent with the full context of the user's request.

The user message after `/orch:parallel` contains tasks that can be executed in parallel.

Use: `@agent-orch-parallel [user's request]`
