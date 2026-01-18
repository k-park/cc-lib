# Ralph Context Management Strategy

## Overview

This document defines the context allocation strategy for the RALPH loop, based on Geoff Huntley's original Ralph Wiggum Loop methodology.

## Core Principle: Context Window as Array

> "Context windows are tokens... I want people to think about this as an array and memory management, mallocing an array."
> -- Geoffrey Huntley

### Key Concepts

1. **Context Window = Array**
   - Think of the context window as a fixed-size array
   - Each loop iteration `malloc`s new content into this array
   - The "sliding window" means older content may be dropped

2. **Deterministic Allocation**
   - Always include the same core elements in each iteration
   - Maintain a clear hierarchy of what gets included

3. **Compaction = Lossy Function**
   - Like downloading and re-uploading a video 1000 times
   - Each compaction loses quality (specifications get dropped)
   - Avoid compaction at all costs

## Context Allocation Hierarchy

### Tier 1: Always Include (Non-negotiable)
```
1. Goal/Objective (succinct, < 200 tokens)
2. Current iteration number
3. Last result/status
4. Next immediate action (one thing only)
```

### Tier 2: Include When Relevant
```
1. Error messages (only when troubleshooting)
2. Test results (only when they fail)
3. File paths (only for files being modified)
```

### Tier 3: Never Include (Avoid)
```
1. Full file contents (use read tools instead)
2. Historical conversation (beyond last 2-3 turns)
3. Unrelated project context
4. Multiple alternative approaches
```

## The "One Thing" Rule

> "The thought that you should only pick one in the loop."

Each iteration should focus on exactly one task. This:
- Minimizes context allocation
- Reduces time in "dumb zone"
- Prevents compaction events
- Improves determinism

## Compaction Detection

### Warning Signs
You are approaching compaction when:
- Context usage exceeds 60-70% of advertised limit
- The model starts "forgetting" earlier instructions
- The model suggests shortcuts or comments out code
- Responses become less coherent

### Mitigation Strategies
1. **Reduce allocation**: Remove Tier 3 content immediately
2. **Start fresh**: "New chat = new array" - create a new session
3. **Summarize**: Condense older iterations to brief status
4. **Externalize**: Move large content to files, reference by path

## Context Hygiene Rules

### Rule 1: New Chat = New Array
Each new objective should start in a fresh chat session. Never reuse context from unrelated goals.

### Rule 2: Measure Usage
Track your context usage:
- Advertised limit: ~200k tokens (marketing number)
- Model overhead: ~16k tokens
- Harness overhead: ~16k tokens (Cursor, Claude Code, etc.)
- **Real usable limit: ~120k-170k tokens**

Stay under 60% (72k-102k tokens) to avoid the "dumb zone".

### Rule 3: Allocate Deterministically
Always include the same structure:
```markdown
## RALPH Loop Context

### Objective
[One sentence goal]

### Success Criteria
- [Criterion 1]
- [Criterion 2]

### Current Iteration: N

### Last Result
[Brief summary of what happened]

### Next Action
[One specific thing to do]
```

## Practical Example

### Bad Context Allocation (Leads to Compaction)
```
- Entire file contents of 10 files (50k tokens)
- Full conversation history (80k tokens)
- Multiple alternative approaches (20k tokens)
- Vague goal description (5k tokens)
Total: 155k tokens -> COMPACTION EVENT
```

### Good Context Allocation (Avoids Compaction)
```
- Succinct objective (200 tokens)
- Current iteration + last result (500 tokens)
- One file path to modify (100 tokens)
- One specific action (200 tokens)
Total: 1k tokens -> No compaction
```

## References

- [Inventing the Ralph Wiggum Loop](https://linearb.io/dev-interrupted/podcast/inventing-the-ralph-wiggum-loop)
- [Podcast Transcript](https://podcasttranscript.ai/library/inventing-the-ralph-wiggum-loop-creator-geoffrey)
