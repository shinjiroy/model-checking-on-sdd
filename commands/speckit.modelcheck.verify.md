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

### Step 4: Parse and Interpret Verification Output

#### 4.1 Parse Results

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

#### 4.2 Extract Counterexamples (for failures)

For each failed property, extract the counterexample structure:

```text
=== COUNTEREXAMPLE: PropertyName ===
[Assertion]
check PropertyName for 5 but 8 Int

[Skolem Variables]
$PropertyName_x = Entity$0
$PropertyName_y = Entity$1

[Instance Data]
Entity$0:
  field1: value1
  field2: value2
```

**CRITICAL - Instance Data Interpretation:**

Instance Data can appear in two forms:

1. **Populated Instance Data** (common for `run` commands):
   ```text
   [Instance Data]
   Order$0:
     state: Confirmed
     totalAmount: 100
   ```
   → Direct interpretation: use the provided values

2. **Empty Instance Data** (common for `check` commands):
   ```text
   [Instance Data]
   (empty - no field values in counterexample)
   ```
   → **This is normal Alloy behavior for assertion violations**
   → Must infer the violation from:
      - Skolem variable bindings
      - The assertion structure in the .als file
      - Signature constraints in the model

#### 4.3 Interpret Empty Instance Data Cases

When Instance Data is empty, follow these steps:

**Step 1**: Identify the Skolem variable(s)
```text
[Skolem Variables]
$PropertyName_o = Order$0
```
This tells you: "There exists an Order (called Order$0) that violates the assertion"

**Step 2**: Locate the assertion in the .als file
```alloy
assert PropertyName {
  all o: Order | Precondition[o] implies Invariant[o]
}
```

**Step 3**: Determine what violated
- Skolem variable exists → `Precondition[o]` is TRUE
- Assertion failed → `Invariant[o]` is FALSE
- Therefore: The model allows a state where Precondition holds but Invariant doesn't

**Step 4**: Infer concrete scenario from model constraints
Read the signature definitions and facts to construct a plausible scenario:

| Field | Possible Value | Why |
|-------|---------------|-----|
| field1 | value_range | Based on sig constraints |
| field2 | missing_check | No constraint enforcing invariant |

**Example:**

```text
[Skolem Variables]
$TotalMismatch_o = Order$0

[Instance Data]
(empty - no field values in counterexample)
```

From the .als file:
```alloy
assert TotalMismatch {
  all o: Order | sum(o.items.price) = o.totalAmount
}
```

Interpretation:
- Order$0 exists where: sum(items.price) ≠ totalAmount
- Concrete scenario: Order with items totaling $100 but totalAmount set to $150
- Root cause: No constraint in the model enforces this equality

### Step 5: Update Properties Document

Based on verification results, update `specs/[FEATURE_NAME]/formal/properties.md`:

Change status indicators:
- `⬜ Not verified` → `✅ PASS` or `❌ FAIL`
- Add verification date
- Add notes about counterexamples (if any)

Example update:

~~~markdown
### 1. NoDoublePurchase
- **Type**: Safety Property
- **Description**: No user can purchase the same product twice simultaneously
- **Command**: `check NoDoublePurchase for 5`
- **Status**: ✅ PASS
- **Last Verified**: [DATE]
- **Scope**: for 5
- **Verified via**: Docker CLI (automatic)
- **Notes**: No counterexample found within scope
~~~

### Step 6: Update Verification Log and Analyze Failures

Create or append to `specs/[FEATURE_NAME]/formal/verification-log.md`.

**First, check the previous verification session** in the log file to compare results.

**For each failed property**, perform analysis using the interpretation steps from Step 4.3 and include it in the log entry.

**Example analysis**:

If a property `NoNegativeBalance` fails with counterexample:
- Skolem: `$NoNegativeBalance_u = User$0`
- Instance Data: `User$0.balance = -5`

The analysis would be:
1. **Locate assertion**: `assert NoNegativeBalance { all u: User | u.balance >= 0 }`
2. **Interpret**: Counterexample shows User$0 with balance = -5, violating the invariant
3. **Root cause**: Purchase predicate allows balance to go negative
4. **Fix**: Add constraint to purchase predicate: `uAfter.balance >= 0`

#### Case A: Results differ from previous session (or first run)

Append a full session entry:

~~~markdown
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

**Analysis**:

1. **Locate the assertion** in `.als` file:
   ```alloy
   assert FailedPropertyName {
     all o: Order | SomePredicate[o] implies SomeInvariant[o]
   }
   ```
   Example: `assert NoNegativeBalance { all u: User | u.balance >= 0 }`

2. **Interpret the counterexample**:
   - Skolem variable `$FailedPropertyName_o = Order$0` shows which instance violates
   - If Instance Data is empty, follow the interpretation steps in Step 4.3
   - Example: `$NoNegativeBalance_u = User$0` with `User$0.balance = -5` means User$0 violates the balance >= 0 constraint

3. **Determine root cause**:
   [Why it fails - missing constraint, design gap, etc.]
   Example: Purchase predicate allows balance to go negative because it doesn't check `uAfter.balance >= 0`

**Fix**:
[Specific action - e.g., "Add constraint: sum(items.discount) = totalDiscount" to predicate SomePredicate]
Example: "Add constraint `uAfter.balance >= 0` to purchase predicate" or "Add fact: `all u: User | u.balance >= 0`"

### Actions Required

- [ ] [Action items based on failures]
~~~

#### Case B: Results identical to previous session

Append a brief entry only:

~~~markdown
---
## Verification Session: [TIMESTAMP]

**Scope Used**: for [SCOPE_NUMBER]
**Result**: No change from previous session ([X]/[Y] properties passed)
~~~

### Step 7: Summary Report

Provide a clear summary:

~~~markdown
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
~~~

## Output Files Modified

1. `specs/[FEATURE_NAME]/formal/properties.md` - Updated with results
2. `specs/[FEATURE_NAME]/formal/verification-log.md` - Appended with session log

## Important Notes

- **Automatic execution**: This command runs verify.sh automatically - no manual steps required
- **Scope sensitivity**: Results depend on scope (for N) - larger scopes take longer but are more thorough
- **Counterexamples are valuable**: Failures reveal important edge cases before implementation
- **Re-run after fixes**: After modifying the model, run this command again to verify fixes
