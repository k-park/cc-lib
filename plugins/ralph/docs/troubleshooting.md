# Ralph Troubleshooting Guide

## Overview

Common issues, failure modes, and solutions for RALPH loops.

## Quick Diagnostics

### Is the Loop Stuck?

**Symptoms:**
- Same iteration repeating
- No progress on success criteria
- Context growing without results

**Diagnosis:**
```markdown
**Check**: What iteration are we on?
**Check**: What was the last successful change?
**Check**: Is context usage > 60%?
```

**Solutions:**
1. Stop the loop with `/ralph:stop`
2. Review what's been accomplished
3. Start fresh with refined scope

### Is the Model "Forgetting"?

**Symptoms:**
- Instructions are ignored
- Earlier decisions are revisited
- Inconsistent behavior

**Diagnosis:**
```markdown
**Check**: Are we in the "dumb zone" (>60% context)?
**Check**: Have we had a compaction event?
**Check**: Is the conversation too long?
```

**Solutions:**
1. Check context usage immediately
2. Summarize progress so far
3. Consider starting a fresh loop with carry-over context

## Common Failure Modes

### Failure Mode 1: Context Compaction

**What Happens:**
The model compacts the context window and drops critical specifications.

**Symptoms:**
- Model starts making things up
- Specifications are "forgotten"
- Decisions contradict earlier agreements

**Example:**
```
Iteration 1: "Build a REST API for user management"
Iteration 5: [Compaction event]
Iteration 6: "I'm making a GraphQL API now..." (WRONG)
```

**Solution:**
1. Stop immediately with `/ralph:stop`
2. Don't try to recover in same session
3. Start fresh with clear specifications

**Prevention:**
- Keep context under 60%
- One thing per iteration
- Externalize large content to files

### Failure Mode 2: Scope Creep

**What Happens:**
The loop expands beyond original objectives.

**Symptoms:**
- Success criteria keep changing
- New features being added mid-loop
- Iteration count exceeds expectations

**Example:**
```
Initial: "Add user login"
Iteration 3: "Oh, I should add OAuth too..."
Iteration 7: "And password reset..."
Iteration 15: "Why not add 2FA while we're at it?"
```

**Solution:**
1. Stop with `/ralph:stop`
2. Document what was completed
3. Start new loop for new scope

**Prevention:**
- Define success criteria upfront
- Make them measurable
- Don't add criteria mid-loop

### Failure Mode 3: Infinite Loop

**What Happens:**
The loop keeps trying the same thing without progress.

**Symptoms:**
- Same error repeating
- No new approaches attempted
- Iteration count climbing without results

**Example:**
```
Iteration 5: "Try X" → Error
Iteration 6: "Try X again" → Error
Iteration 7: "Let me try X" → Error
Iteration 8: "One more time with X" → Error
```

**Solution:**
1. Stop with `/ralph:stop`
2. Analyze why approaches are repeating
3. Provide explicit alternative approach
4. Resume with specific guidance

**Prevention:**
- Enable test integration
- Require different approach on failure
- Set max iteration limit

### Failure Mode 4: Test Paralysis

**What Happens:**
Tests keep failing and the loop can't proceed.

**Symptoms:**
- Same test failing repeatedly
- Fixes not addressing root cause
- No progress on actual feature

**Example:**
```
Iteration 3: Implement feature → Test fails
Iteration 4: Fix test → Test fails differently
Iteration 5: Fix test → Test fails again
Iteration 6: Fix test → Still failing
```

**Solution:**
1. Check if test is correct
2. Verify requirements match test
3. Consider updating test if it's wrong
4. Skip specific test if blocking (with documentation)

**Prevention:**
- Ensure tests are valid before starting
- Use fail_fast mode
- Allow test waiver with explicit reason

### Failure Mode 5: Context Anxiety

**What Happens:**
Model gets anxious about running out of context and makes poor decisions.

**Symptoms:**
- Code gets commented out instead of fixed
- "Quick and dirty" solutions
- Quality degradation

**Example:**
```
Iteration 8: "I'm running low on context, so I'll just
comment out this validation and add a TODO..."
```

**Solution:**
1. Stop before quality degrades
2. Start fresh loop
3. Prioritize quality over speed

**Prevention:**
- Keep context under 50% for safety
- Don't let it approach 70%
- Monitor context usage

## Error Resolution Patterns

### Pattern 1: The "Try Different Approach" Pattern

```markdown
## Current Situation
- Attempted: [Approach A]
- Result: [Error/Failure]
- Iterations stuck: N

## Requested Action
Try a fundamentally different approach. Don't repeat:
- [What was tried that didn't work]

## Alternative to Consider
- [Suggestion for different direction]

## Resume
Please continue the loop with this new approach.
```

### Pattern 2: The "Context Reset" Pattern

```markdown
## What Was Accomplished
- [Completed item 1]
- [Completed item 2]
- [Completed item 3]

## Current State
- [Where we left off]
- [File modifications made]
- [Decisions reached]

## What's Next
- [Remaining work]
- [New context summary]
- [Carry over these key points]

## Resume
Start fresh loop with this context.
```

### Pattern 3: The "Unblock" Pattern

```markdown
## Blocker
- [Error or issue]
- [What's been tried]
- [Why it's stuck]

## Analysis
- [Root cause if known]
- [Potential solutions]

## Requested Action
- [Specific unblocking step]
- [What to try next]

## Resume
Continue loop after resolving blocker.
```

## Platform-Specific Issues

### Claude Code Specific

**Issue:** Skill context limits
**Symptom:** Loop stops unexpectedly
**Solution:** Break into smaller loops

**Issue:** Tool calling overhead
**Symptom:** Slow iterations
**Solution:** Minimize tool calls per iteration

### Cursor Specific

**Issue:** Context window varies by model
**Symptom:** Different behavior on different models
**Solution:** Adjust context threshold per model

**Issue:** .cursorrules conflicts
**Symptom:** Instructions contradict each other
**Solution:** Review and consolidate rules

## Getting Help

### Before Asking

1. Check this troubleshooting guide
2. Review the best practices
3. Check context usage
4. Review loop status

### Information to Gather

```markdown
## Issue Report

**Objective**: [What was the goal?]

**What Happened**: [Describe the problem]

**Current State**:
- Iteration: N
- Context usage: X%
- Last error: [If any]

**What Was Tried**:
- [Attempt 1]
- [Attempt 2]

**Environment**:
- Tool: [Claude Code / Cursor / Other]
- Model: [Opus / Sonnet / etc.]
- Project type: [Language/framework]
```

### Resources

- [Best Practices Guide](./best-practices.md)
- [Context Strategy](./context-strategy.md)
- [Safety Checks](./safety-checks.md)
- [Test Integration](./test-integration.md)

## Quick Reference

| Symptom | Likely Cause | Quick Fix |
|---------|--------------|-----------|
| Repeating same action | Infinite loop | Stop and redirect |
| Making things up | Compaction | Stop and restart |
| Scope expanding | Scope creep | Stop and re-scope |
| Tests keep failing | Test paralysis | Verify test validity |
| Quality degrading | Context anxiety | Stop and reset |
| Instructions ignored | Dumb zone | Reduce context |
| Can't proceed | Blocked | Unblock manually |

## Prevention Checklist

Before starting a loop:
- [ ] Success criteria defined
- [ ] Context under 40%
- [ ] Tests available and passing
- [ ] Safety hooks configured
- [ ] Scope is single, cohesive objective

During the loop:
- [ ] Monitor context usage
- [ ] Watch for repetition
- [ ] Check test results
- [ ] Verify quality maintained

After the loop:
- [ ] All success criteria met
- [ ] Code committed
- [ ] Documentation updated
- [ ] State preserved for handoff
