# Formal Verification Execution Command (Alloy via Docker CLI)

You are helping execute and document formal verification using Alloy via Docker CLI.

## Tool: Alloy Analyzer (Docker CLI Mode)

This command uses Alloy Analyzer in CLI mode via Docker. This provides:

- Automated verification without GUI
- Consistent environment across team (macOS, WSL, Linux)
- Easy integration into development workflows
- Claude Code-friendly text output

## Context Files

- Alloy Model: `specs/{FEATURE_NAME}/formal/{feature}.als`
- Properties List: `specs/{FEATURE_NAME}/formal/properties.md`
- Previous Log: `specs/{FEATURE_NAME}/formal/verification-log.md` (if exists)
- Verification Script: `verify.sh` (project root)

## Verification Workflow

### Step 1: Check Prerequisites

Verify that required files exist:

```
Required files:
✓ specs/{FEATURE_NAME}/formal/{feature}.als
✓ specs/{FEATURE_NAME}/formal/properties.md
✓ verify.sh (Docker verification script)
✓ docker-compose.yml
```

If missing model, inform user:

```
Error: Formal specification not found. 
Please run `/speckit.formalize` first to generate the Alloy model.
```

If missing Docker setup:

```
Error: Docker verification setup not found.
Please ensure verify.sh and docker-compose.yml are in project root.
```

### Step 2: Execute Verification via Docker CLI

Instruct user to run verification using Docker:

```markdown
## Docker経由でAlloy検証を実行

**プロジェクトルートで以下のコマンドを実行してください:**

```bash
./verify.sh specs/{FEATURE_NAME}/formal/{feature}.als
```

**オプション:**

- スコープを変更: `./verify.sh ... --scope 7`
- タイムアウト変更: `./verify.sh ... --timeout 600`
- イメージ再ビルド: `./verify.sh ... --build`

**検証が完了すると、以下のような出力が表示されます:**

```
================================================
Alloy 形式検証
================================================
ファイル: /specs/{feature}.als
スコープ: 5
タイムアウト: 300秒
出力形式: text
================================================

検証開始...

[Check 1: PropertyName1]
  結果: ✅ PASS (反例なし)
  詳細: 指定されたスコープ内でプロパティが成立

[Check 2: PropertyName2]
  結果: ❌ FAIL (反例発見)
  詳細: [反例の詳細]

[Check 3: PropertyName3]
  結果: ✅ PASS (反例なし)
  詳細: 指定されたスコープ内でプロパティが成立

================================================
検証完了: 3 個のプロパティをチェックしました
================================================
```

検証実行後、出力をコピーしてこのチャットに貼り付けてください。

```

### Step 3: Parse Verification Output

When user provides the verification output, parse it to extract results:

1. **Identify each property checked**
   - Look for `[Check N: PropertyName]` patterns
   
2. **Extract results**
   - `✅ PASS (反例なし)` → Property passed
   - `❌ FAIL (反例発見)` → Property failed
   
3. **Capture counterexample details** (for failures)
   - Extract relevant details from output

4. **Summary**
   - Total properties checked
   - Pass/fail count

### Step 4: Update Properties Document

Based on parsed output, update `specs/{FEATURE_NAME}/formal/properties.md`:

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
- **Last Verified**: {DATE}
- **Scope**: for 5
- **Verified via**: Docker CLI
- **Notes**: No counterexample found within scope

### 2. InventoryConsistency
- **Type**: Safety Property  
- **Description**: Product stock never goes negative
- **Command**: `check InventoryConsistency for 5`
- **Status**: ❌ FAIL
- **Last Verified**: {DATE}
- **Scope**: for 5
- **Verified via**: Docker CLI
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
**Alloy Version**: 6.1.0 (Docker CLI)
**Scope Used**: for {SCOPE_NUMBER}
**Execution Method**: Docker CLI (`verify.sh`)

### Results Summary

| Property | Status | Notes |
|----------|--------|-------|
| NoDoublePurchase | ✅ PASS | No counterexample |
| InventoryConsistency | ❌ FAIL | Concurrent purchase issue |
| BalanceIntegrity | ✅ PASS | Verified within scope |

**Overall**: X/Y properties verified successfully

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

**Feature**: {FEATURE_NAME}
**Date**: {DATE}
**Method**: Docker CLI
**Results**: {X}/{Y} properties verified

### Status
✅ Passed: NoDoublePurchase, BalanceIntegrity
❌ Failed: InventoryConsistency

### Next Steps

**Immediate actions**:
1. Review counterexample for InventoryConsistency
2. Choose a fix strategy (model update or spec clarification)
3. Re-run verification after fixes: `./verify.sh specs/{FEATURE_NAME}/formal/{feature}.als`

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

1. `specs/{FEATURE_NAME}/formal/properties.md` - Updated with results
2. `specs/{FEATURE_NAME}/formal/verification-log.md` - Appended with session log

## Handling Different Scenarios

### Scenario A: All Properties Pass

```
Excellent! All properties verified successfully via Docker CLI. ✓

This means the formal model satisfies all specified properties within 
the checked scope (for {SCOPE}). 

Consider:
- Increasing scope (--scope 7) for more thorough verification
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

### Scenario C: Docker Execution Error

```
The Docker verification encountered an error. Common issues:

1. **Docker not running**: Start Docker Desktop or Docker daemon
2. **Image not built**: Run `./verify.sh --build` first
3. **File path issue**: Ensure path is relative to project root
4. **Alloy syntax error**: Check the .als file for syntax errors

Try running with debug:
./verify.sh specs/{FEATURE_NAME}/formal/{feature}.als --build

If error persists, please share the complete error message.
```

## Important Notes

- **Automated process**: Docker CLI provides automated, reproducible verification
- **Scope sensitivity**: Results depend on scope (for N) - larger scopes take longer
- **Counterexamples are valuable**: Failures reveal important edge cases
- **Iterative process**: Verification → Fix → Re-verify is normal
- **Document everything**: Each verification session should be logged
- **Docker required**: Ensure Docker is running before verification

## Integration with Spec Kit Workflow

This command fits into the workflow as:

```
/speckit.specify   → Create natural language spec
/speckit.plan      → Create technical plan
/speckit.formalize → Generate Alloy model
./verify.sh ...    → Verify formal properties (Docker CLI)
/speckit.verify    → Document results (THIS COMMAND)
/speckit.tasks     → Generate implementation tasks
```

The verification can happen iteratively:

- Run `./verify.sh` to execute verification
- Review output
- Use `/speckit.verify` to document results
- Fix model or spec based on results
- Re-run `./verify.sh`
- Repeat until all properties pass

## Docker-Specific Troubleshooting

### Docker not running

```
Error: Cannot connect to Docker daemon

Solution: Start Docker Desktop (macOS) or Docker daemon (Linux/WSL)
```

### Permission issues

```
Error: Permission denied

Solution: 
- macOS/Linux: Ensure user is in docker group
- WSL: Restart Docker Desktop
```

### Build failures

```
Error: Failed to build Alloy image

Solution: 
1. Check internet connection (downloads Alloy JAR)
2. Verify Dockerfile is present in docker/ directory
3. Try manual build: docker-compose build alloy-verify
```
