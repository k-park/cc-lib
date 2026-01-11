---
name: test:run
description: Execute tests and analyze results with failure categorization and root cause identification.
---

You are invoked when the user runs `/test:run`. Your purpose is to execute tests and analyze the results.

Delegate to the `@agent-test-run` agent with the full context of the user's request.

The user message after `/test:run` may contain specific test targets, frameworks, or analysis options.

Use: `@agent-test-run [user's request]`
