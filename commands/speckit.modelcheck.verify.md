---
description: Execute and document model checking verification using Alloy via Docker CLI. (project)
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).
User input may specify:
- Feature name or path to .als file
- Scope override (e.g., "scope 7")
- Other verification options

## Context Files

- Alloy Model: `specs/[FEATURE_NAME]/formal/[feature].als`
- Properties List: `specs/[FEATURE_NAME]/formal/properties.md`
- Previous Log: `specs/[FEATURE_NAME]/formal/verification-log.md` (if exists)
- Verification Script: `.specify/scripts/bash/verify.sh`

## Outline

### Step 1: Locate Alloy Model

Find the Alloy model file to verify:

1. If user specified a path in input, use that
2. Otherwise, search for `.als` files in `specs/[FEATURE_NAME]/formal/`
3. If multiple models found, ask user which one to verify

If no model found:

```
Error: Alloy model not found.
Please run `/speckit.modelcheck.formalize` first to generate the Alloy model.
```

### Step 2: Check Prerequisites

Verify that required files exist:

- `.specify/scripts/bash/verify.sh` or project root `verify.sh`
- `docker-compose.yaml` or `docker-compose.yml`

If missing Docker setup:

```
Error: Docker verification setup not found.
Please ensure verify.sh and docker-compose.yaml exist.
```

### Step 3: Execute Verification

**Use the Bash tool** to run verification automatically:

```bash
.specify/scripts/bash/verify.sh specs/[FEATURE_NAME]/formal/[feature].als --scope [SCOPE]
```

Default scope is 5. Use scope from user input if specified.

If the script is at project root instead:

```bash
./verify.sh specs/[FEATURE_NAME]/formal/[feature].als --scope [SCOPE]
```

**Important**: Run this command and capture the output. Do NOT ask the user to run it manually.

### Step 4: Parse Verification Output

From the verification output, extract:

1. **Each property checked**
   - Check commands: `✅ PASS: PropertyName` or `❌ FAIL: PropertyName (counterexample found)`
   - Run commands: `ℹ️  RUN: PropertyName - instance found` or `ℹ️  RUN: PropertyName - no instance`
   - Unknown results: `⚠️  UNKNOWN: PropertyName (result)`

2. **Errors** (if any)
   - Syntax/Parse errors: `🚫 Error: ...` or `🚫 Syntax error ...`

3. **Results interpretation**
   - `✅ PASS` → No counterexample found (property holds within scope)
   - `❌ FAIL` → Counterexample found (property violated)
   - `ℹ️  RUN - instance found` → Model is satisfiable (good)
   - `ℹ️  RUN - no instance` → Model may be over-constrained (investigate)

4. **Summary line**
   - Format: `Summary: N/M checks passed`
   - If failures: `⚠️  N check(s) FAILED`

### Step 5: Update Properties Document

Based on verification results, update `specs/[FEATURE_NAME]/formal/properties.md`:

Change status indicators:
- `⬜ Not verified` → `✅ PASS` or `❌ FAIL`
- Add verification date
- Add scope used
- Add notes about counterexamples (if any)

Example update:

```markdown
### 1. NoDoublePurchase
- **Type**: Safety Property
- **Description**: No user can purchase the same product twice simultaneously
- **Command**: `check NoDoublePurchase for 5`
- **Status**: ✅ PASS
- **Last Verified**: [DATE]
- **Scope**: for 5
- **Verified via**: Docker CLI (automatic)
- **Notes**: No counterexample found within scope
```

### Step 6: Update Verification Log

Create or append to `specs/[FEATURE_NAME]/formal/verification-log.md`.

**First, check the previous verification session** in the log file to compare results.

#### Case A: Results differ from previous session (or first run)

Append a full session entry:

```markdown
---
## Verification Session: [TIMESTAMP]

**Verifier**: Claude Code (automatic)
**Model Version**: [GIT_COMMIT or DATE]
**Alloy Version**: 6.1.0 (Docker CLI)
**Scope Used**: for [SCOPE_NUMBER]
**Execution Method**: Docker CLI (automatic via /speckit.modelcheck.verify)

### Results Summary

| Property | Status | Notes |
|----------|--------|-------|
| NoDoublePurchase | ✅ PASS | No counterexample |
| InventoryConsistency | ❌ FAIL | Concurrent purchase issue |
| BalanceIntegrity | ✅ PASS | Verified within scope |

**Overall**: [X]/[Y] properties verified successfully

### Verification Output

```text
[Include the actual Docker verification output]
```

### Failed Properties Detail

#### [FailedPropertyName]
**Counterexample observed**:
[Description from output]

**Analysis**:
[Analyze based on output details]

### Actions Required
- [ ] [Action items based on failures]
```

#### Case B: Results identical to previous session

Append a brief entry only:

```markdown
---
## Verification Session: [TIMESTAMP]

**Scope Used**: for [SCOPE_NUMBER]
**Result**: No change from previous session ([X]/[Y] properties passed)
```

### Step 7: Analyze Failures and Suggest Fixes

For each failed property, provide analysis and suggestions:

```markdown
## Analysis of Failures

### [PropertyName] Failed

**Root cause**: [Analysis of why it failed]

**Suggested fixes**:

**Option A: Add constraint to the model**
```alloy
fact [ConstraintName] {
    // Fix suggestion
}
```

**Option B: Strengthen preconditions**
```alloy
pred [operationName][...] {
    // Updated preconditions
}
```

**Option C: Refine spec.md**
If the counterexample reveals a genuine business logic gap, update `spec.md` to clarify the requirements.

**Recommendation**: [Which option to start with]
```

### Step 8: Summary Report

Provide a clear summary:

```markdown
## Verification Complete ✓

**Feature**: [FEATURE_NAME]
**Date**: [DATE]
**Method**: Docker CLI (automatic)
**Results**: [X]/[Y] properties verified

### Status
✅ Passed: [list of passed properties]
❌ Failed: [list of failed properties] (if any)

### Documentation Updated
- ✓ `formal/properties.md` - Status updated with verification results
- ✓ `formal/verification-log.md` - Session recorded with details

### Next Steps
[If all passed]:
- Consider increasing scope for more thorough verification
- Proceed to `/speckit.tasks` for implementation

[If some failed]:
1. Review the counterexamples above
2. Choose a fix strategy (model update or spec clarification)
3. Apply fixes and re-run `/speckit.modelcheck.verify`

**Would you like me to**:
- Apply suggested fixes to the Alloy model
- Help interpret the counterexample details
- Increase verification scope and re-verify
```

## Output Files Modified

1. `specs/[FEATURE_NAME]/formal/properties.md` - Updated with results
2. `specs/[FEATURE_NAME]/formal/verification-log.md` - Appended with session log

## Important Notes

- **Automatic execution**: This command runs verify.sh automatically - no manual steps required
- **Scope sensitivity**: Results depend on scope (for N) - larger scopes take longer but are more thorough
- **Counterexamples are valuable**: Failures reveal important edge cases before implementation
- **Re-run after fixes**: After modifying the model, run this command again to verify fixes
