---
description: Execute and document model checking verification using Alloy.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).
User input may specify:
- Feature name or path to .als file
- Timeout override (e.g., "timeout 300")
- Other verification options

**Note**: Scope is specified in the .als file (e.g., `check PropertyName for 5 but 8 Int`), not via command-line options.

## Context Files

- Alloy Model: `specs/[FEATURE_NAME]/formal/[feature].als`
- Properties List: `specs/[FEATURE_NAME]/formal/properties.md`
- Previous Log: `specs/[FEATURE_NAME]/formal/verification-log.md` (if exists)
- Technical Plan: `specs/[FEATURE_NAME]/plan.md` (for counterexample interpretation)
- Data Model: `specs/[FEATURE_NAME]/data-model.md` (if exists)
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

- `.specify/scripts/bash/verify.sh`
- `docker-compose.yaml`

If missing Docker setup:

```
Error: Docker verification setup not found.
Please ensure .specify/scripts/bash/verify.sh and docker-compose.yaml exist.
```

### Step 3: Execute Verification

**Use the Bash tool** to run verification automatically:

```bash
.specify/scripts/bash/verify.sh specs/[FEATURE_NAME]/formal/[feature].als
```

**Options**:
- `--timeout N`: Set timeout in seconds (default: 600)

**Note**: Scope is defined in the .als file itself (e.g., `check PropertyName for 5 but 8 Int`).

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

5. **Counterexamples** (if any failures)
   - Header: `=== COUNTEREXAMPLE: PropertyName ===`
   - Assertion: `[Assertion]` section shows the check command
   - Skolem Variables: `[Skolem Variables]` section shows bound variables (critical for interpretation)
   - Instance Data: `[Instance Data]` section shows concrete values

   **Note**: Instance Data may be empty for `check` commands. This is normal Alloy behavior.
   When empty, use Skolem Variables + Alloy model to interpret the counterexample (see Step 6).

### Step 5: Update Properties Document

Based on verification results, update `specs/[FEATURE_NAME]/formal/properties.md`:

Change status indicators:
- `⬜ Not verified` → `✅ PASS` or `❌ FAIL`
- Add verification date
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

**Counterexample from verification output**:

```text
[Assertion]
check FailedPropertyName for 5 but 8 Int

[Skolem Variables]
$FailedPropertyName_o = Order$0

[Instance Data]
Order$0:
  state: Confirmed
  totalAmount: 100
```

**Interpretation procedure** (especially when Instance Data is empty):

1. **Identify Skolem variable**: `$FailedPropertyName_o = Order$0`
   - This indicates which instance violates the assertion

2. **Find the assertion in .als file**:
   ```alloy
   assert FailedPropertyName {
     all o: Order | SomePredicate[o] implies SomeInvariant[o]
   }
   ```

3. **Analyze the logical meaning**:
   - Skolem `_o = Order$0` means: there exists an Order that satisfies `SomePredicate` but violates `SomeInvariant`
   - Check what constraints are missing in `SomePredicate`

4. **Construct concrete example** (infer from model constraints):
   | Field | Possible Value | Why |
   |-------|----------------|-----|
   | field1 | value1 | Based on sig constraints |
   | field2 | value2 | Missing invariant check |

**Analysis**:
[Explain what scenario violates the property based on the interpretation above]

**Root Cause**:
[Identify the underlying issue - missing constraint, wrong predicate logic, etc.]

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

For each failed property, **read the .als file** and interpret the counterexample:

#### Interpretation Steps

1. **Parse Skolem variable naming convention**:
   - `$PropertyName_o` → quantified variable `o` in the assertion
   - `$PropertyName_i` → quantified variable `i` in the assertion
   - Value (e.g., `Order$0`) → the specific instance that violates the property

2. **Locate assertion in .als file**:
   ```alloy
   assert PropertyName {
     all o: Order | Precondition[o] implies Invariant[o]
   }
   ```

3. **Determine violation type**:
   - Skolem exists → `Precondition[o]` is true BUT `Invariant[o]` is false
   - Check what `Precondition` allows that `Invariant` forbids

4. **Trace to root cause**:
   - Missing constraint in predicate?
   - Incorrect arithmetic (Int overflow)?
   - Unintended state combination?

#### Analysis Template

```markdown
## Analysis of Failures

### [PropertyName] Failed

**Skolem interpretation**:
- `$PropertyName_o = Order$0` indicates an Order exists where:
  - `[Precondition]` holds (constraints X, Y, Z satisfied)
  - `[Invariant]` fails (constraint W violated)

**Root cause**:
[Precondition] does not enforce [specific constraint], allowing instances where [describe the violation scenario].

**Concrete example** (inferred):
- Order with items where sum(itemDiscounts) = 25
- But Order.totalDiscount = 30 (mismatch allowed)

**Suggested fixes**:

**Option A: Add constraint to predicate**

```alloy
pred [PredicateName][o: Order] {
    // existing constraints...
    // ADD: enforce the missing invariant
    sum(o.items.discount) = o.totalDiscount
}
```

**Option B: Add fact to model**

```alloy
fact [ConstraintName] {
    all o: Order | sum(o.items.discount) = o.totalDiscount
}
```

**Option C: Refine plan.md**
If the counterexample reveals a genuine technical design gap, update `plan.md` to clarify the design decisions.

**Recommendation**: [Which option to start with and why]
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
