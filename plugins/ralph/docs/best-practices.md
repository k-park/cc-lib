# Ralph Best Practices Guide

## Overview

This guide covers best practices for running effective RALPH loops based on the original Ralph Wiggum Loop methodology.

## The Golden Rules

### 1. One Thing Per Loop
> "If you got this array that you're mallocing, and then there's some hints in the name of a context window, software engineers should know what a sliding window is. So you got an array, you got a sliding window, the window is only so big, the array is much bigger. So the less that you allocate, then the more the window is going to be out of C."

Each iteration should do exactly one thing:
- ✅ Good: "Add validation to the login function"
- ❌ Bad: "Implement authentication, add database schema, and write tests"

### 2. New Chat = New Array
Never reuse a chat session for a completely different goal. Each new objective deserves a fresh context array.

**Example:**
- Chat 1: "Build a REST API for user management"
- Chat 2 (NEW): "Add frontend for the user API"
- Chat 3 (NEW): "Write deployment scripts"

### 3. Stay Out of the Dumb Zone
Research shows LLMs get dumber when context usage exceeds 60-70%.

**Safe Operating Ranges:**
- Green zone: 0-50% context usage
- Yellow zone: 50-60% - proceed with caution
- Red zone: 60%+ - you're in the dumb zone, stop and reset

## Session Lifecycle

### Starting a RALPH Loop

1. **Define Clear Success Criteria**
   ```markdown
   **Objective**: Add user authentication

   **Success Criteria**:
   - [ ] Users can register with email/password
   - [ ] Users can log in with credentials
   - [ ] Invalid credentials return appropriate error
   - [ ] Sessions persist across page reloads
   ```

2. **Initial Assessment**
   - Current state: What exists?
   - What's missing: What needs to be built?
   - Dependencies: What else is needed?

3. **Start the Loop**
   Use `/ralph:go` and let the loop run autonomously.

### During the Loop

**Do:**
- Monitor context usage
- Let the model self-correct
- Allow multiple iterations
- Be patient with failures

**Don't:**
- Interrupt for minor issues
- Add unrelated tasks mid-loop
- Expand scope mid-execution
- Manually edit without telling the model

### Stopping the Loop

Use `/ralph:stop` when:
- ✅ All success criteria are met
- ✅ You need to change direction
- ✅ An unrecoverable blocker is hit

## Engineering Practices

### Pre-Commit Hooks
RALPH runs wild. Protect your codebase:

```bash
# Example .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: ralph-safety
        name: Ralph Safety Check
        entry: scripts/ralph-safety.sh
        language: script
```

### Test-Driven Loops
Each iteration should:
1. Make a change
2. Run tests
3. Verify results
4. Continue or fix

### Self-Healing Patterns
When errors occur, the loop should:
1. Analyze the error
2. Propose a fix
3. Apply the fix
4. Re-test
5. Continue

## Common Pitfalls

### Pitfall 1: Expanding Scope Mid-Loop
```
Initial: "Add user login"
Mid-loop: "Oh, also add OAuth, and password reset..."
Result: Context bloat, compaction, failure
```

**Fix:** Stop the loop, document what's done, start a new loop for the new scope.

### Pitfall 2: Not Defining Success
```
Initial: "Improve the codebase"
Result: Infinite loop, never "done"
```

**Fix:** Always define specific, testable success criteria upfront.

### Pitfall 3: Reusing Context Across Goals
```
Chat 1: "Build a blog API"
Chat 2: "Now make it pink, and add a checkout..."
Result: Pink REST endpoints
```

**Fix:** New chat = new array. Start fresh for each distinct goal.

## Context Management Checklist

Before starting each loop:
- [ ] Is this a fresh chat or related to the current goal?
- [ ] Are success criteria defined and measurable?
- [ ] Is the scope limited to one cohesive objective?
- [ ] Are tests available to verify progress?

During the loop:
- [ ] Am I staying under 60% context usage?
- [ ] Is each iteration doing only one thing?
- [ ] Are tests passing before continuing?

After the loop:
- [ ] Did we meet all success criteria?
- [ ] Is the code committed?
- [ ] Is the state documented for handoff?

## Moving Toward Gas Town

The Ralph loop is Figure 5 in the evolution toward Gas Town (multi-agent orchestration).

**Progression:**
- Figure 5: Single Ralph loop (you are here)
- Figure 6: Multiple Ralph loops, learning failure modes
- Figure 7: Many spinning plates, chaos emerges
- Figure 8: Gas Town - orchestrated multi-agent system

**Key Learning:**
You must earn your stripes at each figure. Don't skip to Gas Town without understanding why single-loop Ralph works.

## References

- [Original Ralph Loop Discussion](https://linearb.io/dev-interrupted/podcast/inventing-the-ralph-wiggum-loop)
- [Context Strategy](./context-strategy.md)
- [Test Integration](./test-integration.md)
