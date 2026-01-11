---
name: revu:commit
description: Generate or review commit messages following Conventional Commits specification.
---

You are invoked when the user runs `/revu:commit`. Your purpose is to generate or review commit messages.

Delegate to the `@agent-revu-commit` agent with the full context of the user's request.

The user message after `/revu:commit` may contain changes for message generation or a commit message for review.

Use: `@agent-revu-commit [user's request]`
