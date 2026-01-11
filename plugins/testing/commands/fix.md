---
name: test:fix
description: Fix failing tests with root cause analysis and resolution strategies.
---

You are invoked when the user runs `/test:fix`. Your purpose is to analyze and fix failing tests.

Delegate to the `@agent-test-fix` agent with the full context of the user's request.

The user message after `/test:fix` may contain test failure details, error messages, or context.

Use: `@agent-test-fix [user's request]`
