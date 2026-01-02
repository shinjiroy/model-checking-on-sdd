---
description: Execute and document model checking verification using Alloy via Docker CLI. (project)
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Context Files

- Alloy Model: `specs/[FEATURE_NAME]/formal/[feature].als`
- Properties List: `specs/[FEATURE_NAME]/formal/properties.md`
- Previous Log: `specs/[FEATURE_NAME]/formal/verification-log.md` (if exists)
- Verification Script: `.specify/scripts/bash/verify.sh`

## Outline

### Step 1: Check Prerequisites

Verify that required files exist:

```
Required files:
✓ specs/[FEATURE_NAME]/formal/[feature].als
✓ specs/[FEATURE_NAME]/formal/properties.md
✓ .specify/scripts/bash/verify.sh (Docker verification script)
✓ docker-compose.yaml
```

If missing model, inform user:

```
Error: Alloy model not found.
Please run `/speckit.modelcheck.formalize` first to generate the Alloy model.
```

If missing Docker setup:

```
Error: Docker verification setup not found.
Please ensure .specify/scripts/bash/verify.sh and docker-compose.yaml exist.
```

### Step 2: Execute Verification via Docker CLI

Instruct user to run verification using Docker:

```markdown
## Run Alloy Model Checking via Docker

**Run the following command from the project root:**

```bash
.specify/scripts/bash/verify.sh specs/[FEATURE_NAME]/formal/[feature].als
```

**Options:**

- Change scope: `.specify/scripts/bash/verify.sh ... --scope 7`
- Change timeout: `.specify/scripts/bash/verify.sh ... --timeout 600`
- Rebuild image: `.specify/scripts/bash/verify.sh ... --build`

**After verification completes, you will see output like:**

```
================================================
Alloy Model Checking
================================================
File: /specs/[feature].als
Scope: 5
Timeout: 300s
Output format: text
================================================

Starting verification...

[Check 1: PropertyName1]
  Result: ✅ PASS (no counterexample)
  Details: Property holds within specified scope

[Check 2: PropertyName2]
  Result: ❌ FAIL (counterexample found)
  Details: [counterexample details]

[Check 3: PropertyName3]
  Result: ✅ PASS (no counterexample)
  Details: Property holds within specified scope

================================================
Verification complete: 3 properties checked
================================================
```

After running verification, copy the output and paste it into this chat.
```

### Step 3: Parse Verification Output

When user provides the verification output, parse it to extract results:

1. **Identify each property checked**
   - Look for `[Check N: PropertyName]` patterns

2. **Extract results**
   - `✅ PASS (no counterexample)` → Property passed
   - `❌ FAIL (counterexample found)` → Property failed

3. **Capture counterexample details** (for failures)
   - Extract relevant details from output

4. **Summary**
   - Total properties checked
   - Pass/fail count

### Step 4: Update Properties Document

Based on parsed output, update `specs/[FEATURE_NAME]/formal/properties.md`:

Change status indicators:
- `⬜ Not verified` → `✅ PASS` or `❌ FAIL`
- Add verification date
- Add scope used
- Add notes about counterexamples (if any)

Example:

```markdown
### 1. NoDoublePurchase
- **Type**: Safety Property
- **Description**: No user can purchase the same product twice simultaneously
- **Command**: `check NoDoublePurchase for 5`
- **Status**: ✅ PASS
- **Last Verified**: [DATE]
- **Scope**: for 5
- **Verified via**: Docker CLI
- **Notes**: No counterexample found within scope

### 2. InventoryConsistency
- **Type**: Safety Property
- **Description**: Product stock never goes negative
- **Command**: `check InventoryConsistency for 5`
- **Status**: ❌ FAIL
- **Last Verified**: [DATE]
- **Scope**: for 5
- **Verified via**: Docker CLI
- **Counterexample**: Found scenario where concurrent purchases reduce stock below zero
- **Action Required**: Add synchronization constraints or stock check
```

### Step 5: Update Verification Log

Create or append to `specs/[FEATURE_NAME]/formal/verification-log.md`:

```markdown
---
## Verification Session: [TIMESTAMP]

**Verifier**: [USER_NAME or "Team Member"]
**Model Version**: [GIT_COMMIT or DATE]
**Alloy Version**: 6.1.0 (Docker CLI)
**Scope Used**: for [SCOPE_NUMBER]
**Execution Method**: Docker CLI (`verify.sh`)

### Results Summary

| Property | Status | Notes |
|----------|--------|-------|
| NoDoublePurchase | ✅ PASS | No counterexample |
| InventoryConsistency | ❌ FAIL | Concurrent purchase issue |
| BalanceIntegrity | ✅ PASS | Verified within scope |

**Overall**: [X]/[Y] properties verified successfully

### Docker Output

```
[Include relevant portions of Docker verification output]
```

### Failed Properties Detail

#### InventoryConsistency
**Counterexample observed**:
Two users simultaneously purchasing the last item in stock resulted in stock = -1

**Analysis**:
[Analyze based on output details]

### Actions Required
- [ ] Fix: Add fact to ensure atomic stock operations
- [ ] Fix: Add precondition check: p.stock > 0 before purchase
- [ ] Re-verify after model update
```

### Step 6: Analyze Failures and Suggest Fixes

For each failed property, provide analysis and suggestions:

```markdown
## Analysis of Failures

### InventoryConsistency Failed

**Root cause**: The model allows concurrent operations without proper synchronization.

**Suggested fixes**:

**Option A: Add constraint to the model**
```alloy
fact AtomicStockOperations {
    // Ensure stock updates are atomic
    no disj p1, p2: Purchase |
        p1.product = p2.product and
        p1.timestamp = p2.timestamp
}
```

**Option B: Strengthen preconditions**

```alloy
pred purchase[u: User, p: Product] {
    // Existing preconditions
    u.balance >= p.price
    p.stock > 0  // Ensure stock check happens atomically

    // Add: no other pending purchase for this product
    no other: Purchase | other.product = p and other.status = Pending
}
```

**Option C: Refine spec.md**
If the counterexample reveals a genuine business logic gap, update `spec.md` to clarify:

- How concurrent purchases should be handled
- Whether optimistic or pessimistic locking is used
- Stock reservation mechanism

**Recommendation**: Start with Option B (strengthen preconditions) as it's most practical.

Would you like me to:

1. Update the Alloy model with the suggested fix
2. Suggest changes to spec.md
3. Generate additional test scenarios
```

### Step 7: Summary Report

Provide a clear summary:

```markdown
## Verification Complete ✓

**Feature**: [FEATURE_NAME]
**Date**: [DATE]
**Method**: Docker CLI
**Results**: [X]/[Y] properties verified

### Status
✅ Passed: NoDoublePurchase, BalanceIntegrity
❌ Failed: InventoryConsistency

### Next Steps

**Immediate actions**:
1. Review counterexample for InventoryConsistency
2. Choose a fix strategy (model update or spec clarification)
3. Re-run verification after fixes: `.specify/scripts/bash/verify.sh specs/[FEATURE_NAME]/formal/[feature].als`

**Documentation updated**:
- ✓ `formal/properties.md` - Status updated with verification results
- ✓ `formal/verification-log.md` - Session recorded with details

**Would you like me to**:
- Apply suggested fixes to the Alloy model
- Help interpret the counterexample details
- Update spec.md to address the issues found
- Increase verification scope for more thorough checking
```

## Output Files Modified

1. `specs/[FEATURE_NAME]/formal/properties.md` - Updated with results
2. `specs/[FEATURE_NAME]/formal/verification-log.md` - Appended with session log

## Important Notes

- **Scope sensitivity**: Results depend on scope (for N) - larger scopes take longer
- **Counterexamples are valuable**: Failures reveal important edge cases
