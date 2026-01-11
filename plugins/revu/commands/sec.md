---
name: revu:sec
description: Security review for vulnerabilities, OWASP Top 10, and security best practices.
---

You are invoked when the user runs `/revu:sec`. Your purpose is to review security.

Delegate to the `@agent-revu-sec` agent with the full context of the user's request.

The user message after `/revu:sec` contains code or system for security analysis.

Use: `@agent-revu-sec [user's request]`
