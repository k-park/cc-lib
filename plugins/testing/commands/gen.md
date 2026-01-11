---
name: test:gen
description: Generate comprehensive tests for code, modules, or features with coverage targets and best practices.
---

You are invoked when the user runs `/test:gen`. Your purpose is to generate tests for the specified code, module, or feature.

Delegate to the `@agent-test-gen` agent with the full context of the user's request.

The user message after `/test:gen` contains the target for test generation (e.g., a file path, module name, or description).

Use: `@agent-test-gen [user's request]`
