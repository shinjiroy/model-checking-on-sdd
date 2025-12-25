# Formal Verification Execution Command (Alloy)

You are helping execute and document formal verification using Alloy Analyzer.

## Tool: Alloy Analyzer

Alloy Analyzer is a **GUI application** with visual feedback. This command provides a **semi-automated workflow** that:
1. Guides the user through manual verification in Alloy Analyzer
2. Collects and documents results
3. Updates tracking documents
4. Suggests fixes for any failures

## Context Files

- Alloy Model: `specs/{FEATURE_NAME}/formal/{feature}.als`
- Properties List: `specs/{FEATURE_NAME}/formal/properties.md`
- Previous Log: `specs/{FEATURE_NAME}/formal/verification-log.md` (if exists)

## Verification Workflow

### Step 1: Check Prerequisites

Verify that required files exist:
```
Required files:
✓ specs/{FEATURE_NAME}/formal/{feature}.als
✓ specs/{FEATURE_NAME}/formal/properties.md
```

If missing, inform user:
```
Error: Formal specification not found. 
Please run `/speckit.formalize` first to generate the Alloy model.
```

### Step 2: Guide User Through Verification

Since Alloy Analyzer is a GUI tool, provide clear instructions:

```markdown
## Verification Instructions

**To verify the formal specification, follow these steps:**

1. **Open Alloy Analyzer**
   - Download from: https://alloytools.org/download.html (if not installed)
   - Launch the application

2. **Load the Model**
   - File → Open
   - Navigate to: `specs/{FEATURE_NAME}/formal/{feature}.als`

3. **Execute Verification Commands**
   
   You'll see these `check` commands in the model:
   {List all check commands from the .als file}
   
   For each command:
   - Click the "Execute" button next to the command
   - Wait for the analysis to complete (a few seconds)
   - Note the result:
     * **Green checkmark** = Property PASSED (no counterexample found)
     * **Red X** = Property FAILED (counterexample found)

4. **Review Counterexamples** (if any failures)
   - Alloy will display an instance graph showing the counterexample
   - Click through the instance to understand why the property failed
   - Use "Next" button to see alternative counterexamples

5. **Report Results**
   
   Please provide verification results in this format:
   ```
   Property: [Name]
   Status: PASS / FAIL
   Scope: for X
   Notes: [Any observations or counterexample description]
   ```
```

### Step 3: Collect Results from User

Ask the user to provide results:
```
Please run the verification in Alloy Analyzer and report the results here.

For each property, tell me:
- Property name
- Status (PASS/FAIL)
- If FAIL: Brief description of the counterexample you saw

Example format:
NoDoublePurchase: PASS
InventoryConsistency: FAIL - Found case where stock becomes negative with concurrent purchases
BalanceIntegrity: PASS

I'll update the tracking documents once you provide the results.
```

### Step 4: Update Properties Document

Based on user's results, update `specs/{FEATURE_NAME}/formal/properties.md`:

Change status indicators:
- `⬜ Not verified` → `✅ PASS` or `❌ FAIL`
- Add verification date
- Add notes about counterexamples (if any)

Example:
```markdown
### 1. NoDoublePurchase
- **Type**: Safety Property
- **Description**: No user can purchase the same product twice simultaneously
- **Command**: `check NoDoublePurchase for 5`
- **Status**: ✅ PASS
- **Last Verified**: {DATE}
- **Scope**: for 5
- **Notes**: No counterexample found within scope

### 2. InventoryConsistency
- **Type**: Safety Property  
- **Description**: Product stock never goes negative
- **Command**: `check InventoryConsistency for 5`
- **Status**: ❌ FAIL
- **Last Verified**: {DATE}
- **Scope**: for 5
- **Counterexample**: Found scenario where concurrent purchases reduce stock below zero
- **Action Required**: Add synchronization constraints or stock check
```

### Step 5: Update Verification Log

Create or append to `specs/{FEATURE_NAME}/formal/verification-log.md`:

```markdown
---
## Verification Session: {TIMESTAMP}

**Verifier**: {USER_NAME or "Team Member"}
**Model Version**: {GIT_COMMIT or DATE}
**Alloy Analyzer Version**: {VERSION if available}
**Scope Used**: for {SCOPE_NUMBER}

### Results Summary

| Property | Status | Notes |
|----------|--------|-------|
| NoDoublePurchase | ✅ PASS | No counterexample |
| InventoryConsistency | ❌ FAIL | Concurrent purchase issue |
| BalanceIntegrity | ✅ PASS | Verified within scope |

**Overall**: X/Y properties verified successfully

### Failed Properties Detail

#### InventoryConsistency
**Counterexample observed**: 
Two users simultaneously purchasing the last item in stock resulted in stock = -1

**Instance details**:
- Product: stock = 1
- User1 and User2 both execute purchase
- Final state: stock = -1

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

**Feature**: {FEATURE_NAME}
**Date**: {DATE}
**Results**: {X}/{Y} properties verified

### Status
✅ Passed: NoDoublePurchase, BalanceIntegrity
❌ Failed: InventoryConsistency

### Next Steps

**Immediate actions**:
1. Review counterexample for InventoryConsistency
2. Choose a fix strategy (model update or spec clarification)
3. Re-run verification after fixes

**Documentation updated**:
- ✓ `formal/properties.md` - Status updated with verification results
- ✓ `formal/verification-log.md` - Session recorded with details

**Would you like me to**:
- Apply suggested fixes to the Alloy model
- Help interpret a specific counterexample
- Update spec.md to address the issues found
- Increase verification scope for more thorough checking
```

## Output Files Modified

1. `specs/{FEATURE_NAME}/formal/properties.md` - Updated with results
2. `specs/{FEATURE_NAME}/formal/verification-log.md` - Appended with session log

## Handling Different Scenarios

### Scenario A: All Properties Pass
```
Excellent! All properties verified successfully. ✓

This means the formal model satisfies all specified properties within 
the checked scope (for {SCOPE}). 

Consider:
- Increasing scope (for 7, for 10) for more thorough verification
- Adding additional properties to verify edge cases
- Moving forward with implementation knowing the design is sound
```

### Scenario B: Some Properties Fail
```
Found {N} property violations that need attention.

These counterexamples reveal potential issues in either:
1. The formal model (needs refinement)
2. The specification (incomplete requirements)
3. The intended behavior (needs clarification)

I've provided suggested fixes above. Let's address these before implementation.
```

### Scenario C: User Hasn't Run Verification Yet
```
I'm ready to help document the verification results, but I need you to 
run Alloy Analyzer first.

Follow the instructions in Step 2 above, then report back with the results.
If you encounter any issues with Alloy Analyzer, let me know and I can help troubleshoot.
```

## Important Notes

- **Manual process**: Alloy Analyzer is GUI-based, so full automation isn't practical
- **Scope sensitivity**: Results depend on the scope (for N) - larger scopes take longer but are more thorough
- **Counterexamples are valuable**: Failures aren't bad - they reveal important edge cases
- **Iterative process**: Verification → Fix → Re-verify is normal and expected
- **Document everything**: Each verification session should be logged for traceability

## Integration with Spec Kit Workflow

This command fits into the workflow as:
```
/speckit.specify   → Create natural language spec
/speckit.plan      → Create technical plan
/speckit.formalize → Generate Alloy model (NEW)
/speckit.verify    → Verify formal properties (THIS COMMAND)
/speckit.tasks     → Generate implementation tasks
```

The verification can happen iteratively:
- Initial verification often finds issues
- Fix model or spec
- Re-verify
- Repeat until all properties pass
