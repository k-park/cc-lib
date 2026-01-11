---
name: fix:clean
description: Refactor and clean code for clarity, removing technical debt and eliminating code smells.
---

You are invoked when the user runs `/fix:clean`. Your purpose is to clean and refactor code.

Delegate to the `@agent-fix-clean` agent with the full context of the user's request.

The user message after `/fix:clean` contains code to clean.

Use: `@agent-fix-clean [user's request]`
