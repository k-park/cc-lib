# Ralph Safety Checks & Engineering Safeguards

## Overview

RALPH loops run autonomously. Without proper safeguards, they can cause damage. This document defines safety measures for responsible autonomous coding.

## Philosophy

> "If the idea of autonomous loop within your code base makes you want to Ralph, listen to that feeling. You're an engineer, right? What are you going to do to stop it from dropping the database?"
> -- Geoffrey Huntley

The answer is **engineering**: pre-commit hooks, property-based tests, snapshot tests, and feedback loops.

## Safety Levels

### Level 1: Observation Only (Safest)
- Read-only operations
- No file modifications
- No external API calls
- Use for: analysis, documentation generation

### Level 2: Controlled Execution (Recommended)
- File modifications allowed
- Tests required after changes
- Pre-commit hooks enforced
- Rollback capability maintained
- Use for: feature development, refactoring

### Level 3: Full Autonomy (Advanced)
- Direct deployment to production
- No code review
- Self-healing feedback loops
- Use for: mature projects with comprehensive tests

## Pre-Commit Hooks

### Essential Hooks

```yaml
# .pre-commit-config.yaml
repos:
  # 1. Prevent secrets from being committed
  - repo: https://github.com/Yelp/detect-secrets
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']

  # 2. Code formatting
  - repo: local
    hooks:
      - id: format-code
        name: Format Code
        entry: biome format --write .
        language: system
        types: [code]

  # 3. Linting
  - repo: local
    hooks:
      - id: lint
        name: Lint
        entry: biome lint .
        language: system
        types: [code]

  # 4. Type checking
  - repo: local
    hooks:
      - id: type-check
        name: Type Check
        entry: tsc --noEmit
        language: system
        types: [ts]

  # 5. Run tests
  - repo: local
    hooks:
      - id: ralph-test
        name: Ralph Test Guard
        entry: scripts/ralph-test-guard.sh
        language: script
        pass_filenames: false
```

### Ralph-Specific Guards

```bash
#!/bin/bash
# scripts/ralph-test-guard.sh

# Check if this is a Ralph-generated commit
if git log -1 --pretty=%B | grep -q "RALPH Loop"; then
  echo "RALPH commit detected - running full test suite"
  pytest || exit 1
  echo "RALPH tests passed - allowing commit"
fi
```

## Protected Resources

### Always Protect

1. **Production Databases**
   - Never use real credentials in loops
   - Use mock/stub services
   - Run against test databases only

2. **Secrets & Credentials**
   - Use environment variables
   - Never commit secrets
   - Rotate credentials if accidentally exposed

3. **External APIs**
   - Rate limit awareness
   - Cost monitoring
   - Circuit breakers for failures

4. **Deployments**
   - Feature flags for new code
   - Rollback capability
   - Monitoring and alerting

## Self-Healing Patterns

### Pattern 1: Error Recovery

```markdown
## Error Encountered

**Error**: Database connection failed

**Recovery Steps**:
1. Check if database service is running
2. Verify connection string
3. Test with simplified query
4. If still failing: halt and alert

**Result**: Fixed connection string issue
**Status**: Resumed loop
```

### Pattern 2: Rollback on Failure

```markdown
## Test Failure After Deployment

**Action**: Immediate rollback initiated
**Reason**: Critical tests failing in production
**Rollback Method**: git revert HEAD
**Status**: System stable, investigating failure
```

### Pattern 3: Circuit Breaker

```python
# scripts/ralph-circuit-breaker.py
class CircuitBreaker:
    def __init__(self, failure_threshold=3, timeout=60):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.last_failure_time = None
        self.state = 'closed'  # closed, open, half-open

    def call(self, func):
        if self.state == 'open':
            if time.time() - self.last_failure_time > self.timeout:
                self.state = 'half-open'
            else:
                raise CircuitBreakerOpenError()

        try:
            result = func()
            if self.state == 'half-open':
                self.state = 'closed'
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            if self.failure_count >= self.failure_threshold:
                self.state = 'open'
            raise
```

## Test Categories for Safety

### 1. Property-Based Tests
```python
# Properties that should always hold
@pytest.mark.property
def test_user_id_never_changes(user):
    """User ID should be immutable"""
    original_id = user.id
    user.update(email="new@example.com")
    assert user.id == original_id
```

### 2. Snapshot Tests
```python
# Ensure UI doesn't unexpectedly change
def test_login_page_snapshot():
    page = render LoginPage
    assert page.match_snapshot()
```

### 3. Integration Tests
```python
# Test critical user flows
def test_user_registration_flow():
    response = client.post("/register", json={
        "email": "test@example.com",
        "password": "secure123"
    })
    assert response.status_code == 201
    assert "user_id" in response.json
```

## Monitoring & Observability

### Metrics to Track

1. **Loop Health**
   - Iterations per hour
   - Success/failure ratio
   - Context usage trend

2. **Code Quality**
   - Test pass rate
   - Lint violations
   - Code coverage

3. **System Impact**
   - API call rate
   - Database query count
   - Deployment frequency

### Alerting

```yaml
# alerts.yml
alerts:
  - name: RalphLoopStalled
    condition: iterations_last_hour == 0
    severity: warning

  - name: RalphTestFailure
    condition: consecutive_test_failures >= 3
    severity: critical

  - name: RalphContextFull
    condition: context_usage > 0.9
    severity: warning
```

## Configuration

### Safety Config

```yaml
# .ralph-safety.yaml
safety:
  level: controlled  # observation, controlled, full_autonomy

  protected_resources:
    - production_database
    - api_keys
    - external_apis

  limits:
    max_iterations_per_hour: 60
    max_deployments_per_hour: 10
    max_context_usage: 0.7

  requirements:
    tests_required: true
    pre_commit_hooks: true
    code_review: true  # except for auto-fixes

  rollback:
    enabled: true
    trigger: test_failure
    method: git_revert
```

## Deployment Safety

### Feature Flags

```python
# LaunchDarkly or similar
if feature_flag.enabled("new-auth-system", user):
    # New code from Ralph
    return new_auth_flow()
else:
    # Old stable code
    return old_auth_flow()
```

### Gradual Rollout

1. **Canary**: 1% of traffic
2. **Monitor**: Check error rates, latency
3. **Expand**: 10%, 25%, 50%, 100%
4. **Rollback**: If metrics degrade

## References

- [Best Practices Guide](./best-practices.md)
- [Test Integration](./test-integration.md)
- [Troubleshooting](./troubleshooting.md)
