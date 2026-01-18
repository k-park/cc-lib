# Ralph Test Integration Specification

## Overview

This document defines the test integration interface for the RALPH loop, enabling automated testing after each iteration.

## Philosophy

> "Agents autonomously push to master, no branches, and the deployment happens in under 30 seconds. And then if something goes wrong, I've got feedback loops which feed back into the active session and then it just self-repairs."
> -- Geoffrey Huntley

The RALPH loop should not proceed until tests pass. This creates a self-healing feedback loop.

## Test Execution Interface

### Default Behavior

After each code change, the loop should:

1. **Detect available tests** - Identify test framework in use
2. **Run relevant tests** - Execute tests for changed code
3. **Analyze results** - Parse test output
4. **Decide next action**:
   - Tests pass → Continue to next iteration
   - Tests fail → Analyze failure, fix, re-test

### Test Framework Detection

```yaml
# Priority order for detection
test_frameworks:
  - name: pytest
    trigger: "pytest.ini" or "pyproject.toml with [tool.pytest]"
    command: "pytest"
  - name: jest
    trigger: "package.json with jest script"
    command: "npm test"
  - name: go test
    trigger: "*.go files with _test.go suffix"
    command: "go test ./..."
  - name: cargo test
    trigger: "Cargo.toml"
    command: "cargo test"
  - name: None
    fallback: "Manual testing required"
```

## Integration Pattern

### Loop with Test Integration

```markdown
## Iteration N

**What I'm doing**: [Specific action]

**Why**: [Connection to goal]

**Execute**:
1. [Make the change]
2. Run tests: `[command]`
3. Analyze results

**Result**: [What happened]

**Test Status**: [PASS | FAIL]

**Assessment**:
- If PASS → Continue to next iteration
- If FAIL → Analyze and fix
```

### Test Failure Handling

When tests fail, the loop should:

1. **Capture failure details**
   ```
   FAILED test_auth.py::test_login_invalid_credentials
   AssertionError: Expected 401, got 200
   ```

2. **Analyze the failure**
   ```
   **Analysis**: The login function is not validating credentials
   **Root Cause**: Missing authentication check
   **Fix Strategy**: Add credential validation before returning success
   ```

3. **Apply the fix**
   ```
   **Fixing**: Adding authentication check to login function
   ```

4. **Re-test**
   ```
   **Re-running tests**: pytest test_auth.py::test_login_invalid_credentials
   **Result**: PASS
   ```

5. **Continue loop**

## Configuration

### Project-Level Config

Create `.ralph-config.yaml` in your project root:

```yaml
# Ralph Test Configuration
test:
  enabled: true
  framework: auto  # auto, pytest, jest, go, cargo, none
  command: null    # Override auto-detection
  fail_fast: true  # Stop on first failure
  coverage:
    enabled: false
    minimum: 80

loop:
  max_iterations: 100
  context_threshold: 0.6  # Warn at 60% context usage
```

### Environment Variables

```bash
# Disable tests in loop (not recommended)
RALPH_TESTS_ENABLED=false

# Override test command
RALPH_TEST_COMMAND="pytest -xvs"

# Set context warning threshold
RALPH_CONTEXT_THRESHOLD=0.5
```

## Test Categories

### 1. Unit Tests
- Run after each function/class change
- Fast execution
- Isolated scope

### 2. Integration Tests
- Run after module-level changes
- May require external services
- Slower execution

### 3. End-to-End Tests
- Run after feature completion
- Full system scope
- Slowest execution

## Feedback Loop Patterns

### Pattern 1: Immediate Test Loop
```
Code → Test → Fail → Fix → Test → Pass → Continue
```

### Pattern 2: Batch Test Loop
```
Code → Code → Code → Test → Fail → Fix → Test → Pass → Continue
```

### Pattern 3: Deferred Test Loop
```
Code → Code → Code → Manual Test → Continue
```

**Recommendation:** Use Pattern 1 for best results.

## Examples

### Example 1: Python with Pytest

```markdown
## Iteration 3

**What I'm doing**: Adding login validation

**Execute**:
```python
# auth.py
def login(username, password):
    if not validate_credentials(username, password):
        raise UnauthorizedError()
    return create_session(username)
```

**Test Command**: `pytest tests/test_auth.py -v`

**Result**:
```
tests/test_auth.py::test_login_success PASSED
tests/test_auth.py::test_login_invalid_credentials FAILED
```

**Test Status**: FAIL

**Analysis**: The validation function is not checking correctly

**Fix**: Updating validate_credentials to properly hash and compare

**Re-test**: `pytest tests/test_auth.py::test_login_invalid_credentials -v`

**Result**: PASSED

**Assessment**: Continue to next iteration
```

### Example 2: JavaScript with Jest

```markdown
## Iteration 5

**What I'm doing**: Adding user registration endpoint

**Execute**:
```typescript
app.post('/register', async (req, res) => {
  const { email, password } = req.body;
  const user = await db.createUser(email, password);
  res.json(user);
});
```

**Test Command**: `npm test -- register.test.ts`

**Result**: 5 passed, 2 failed

**Test Status**: FAIL

**Analysis**: Missing email validation and duplicate handling

**Fix**: Adding validation and duplicate checks

**Re-test**: PASS

**Assessment**: Continue to next iteration
```

## Troubleshooting

### No Tests Detected
**Problem**: Ralph can't find any tests
**Solution**:
1. Add test config to `.ralph-config.yaml`
2. Specify test command explicitly
3. Set up basic test scaffold first

### Tests Too Slow
**Problem**: Each iteration takes too long
**Solution**:
1. Use fail_fast mode
2. Run only affected tests
3. Consider test categorization

### Flaky Tests
**Problem**: Tests fail intermittently
**Solution**:
1. Fix the flaky tests first (outside Ralph)
2. Use test retries in config
3. Increase iteration tolerance

## References

- [Best Practices Guide](./best-practices.md)
- [Context Strategy](./context-strategy.md)
- [Safety Checks](./safety-checks.md)
