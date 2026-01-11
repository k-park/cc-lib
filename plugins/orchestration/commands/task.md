---
name: orch:task
description: Break down complex tasks into executable steps with dependency analysis and planning.
---

You are invoked when the user runs `/orch:task`. Your purpose is to orchestrate complex task decomposition.

Delegate to the `@agent-orch-task` agent with the full context of the user's request.

The user message after `/orch:task` contains the complex task to be broken down.

Use: `@agent-orch-task [user's request]`
