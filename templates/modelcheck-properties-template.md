# Verification Properties: [FEATURE_NAME]

**Model File**: `[feature].als`  
**Created**: [DATE]  
**Last Updated**: [DATE]

## Overview

This document tracks the properties verified for [FEATURE_NAME]. Each property represents a guarantee about the system's behavior that has been specified and checked using Alloy.

## Verification Status Legend

- ⬜ **Not verified**: Property defined but not yet checked
- ✅ **PASS**: Property holds within the checked scope (no counterexample found)
- ❌ **FAIL**: Property violated (counterexample found)
- 🔄 **Re-verify needed**: Model or spec updated since last verification

---

## Properties to Verify

<!--
  ACTION REQUIRED: List all assertions defined in your Alloy model.
  Each property should have a corresponding `assert` and `check` command in the .als file.
  Update the status after each verification session.
-->

### 1. [PropertyName1]

- **Type**: Safety Property / Liveness Property / Structural Property
- **Description**: [What this property guarantees]
- **Model Location**: Line XX-XX in `[feature].als`
- **Verification Command**: `check [PropertyName1] for [scope]`
- **Status**: ⬜ Not verified
- **Last Verified**: N/A
- **Scope**: N/A
- **Notes**: [Any additional context]

---

### 2. [PropertyName2]

- **Type**: Safety Property / Liveness Property / Structural Property
- **Description**: [What this property guarantees]
- **Model Location**: Line XX-XX in `[feature].als`
- **Verification Command**: `check [PropertyName2] for [scope]`
- **Status**: ⬜ Not verified
- **Last Verified**: N/A
- **Scope**: N/A
- **Notes**: [Any additional context]

---

### 3. [PropertyName3]

- **Type**: Safety Property / Liveness Property / Structural Property
- **Description**: [What this property guarantees]
- **Model Location**: Line XX-XX in `[feature].als`
- **Verification Command**: `check [PropertyName3] for [scope]`
- **Status**: ⬜ Not verified
- **Last Verified**: N/A
- **Scope**: N/A
- **Notes**: [Any additional context]

---

## Property Categories

<!--
  ACTION REQUIRED: Categorize your properties by type.
  This helps prioritize which properties are most critical.
-->

### Safety Properties

Properties that guarantee "bad things never happen":

- [List safety properties here]

### Liveness Properties

Properties that guarantee "good things eventually happen":

- [List liveness properties here]

### Structural Properties

Properties about the system's structure and relationships:

- [List structural properties here]

---

## Verification Instructions

### Recommended: Docker CLI (automatic)

Run `/speckit.modelcheck.verify` command. This will:

1. Automatically execute verification via Docker
2. Parse results and interpret pass/fail status
3. Update this document with results (status, date, scope)
4. Append session details to `verification-log.md`
5. Suggest fixes for any failed properties

**Scope override**: `/speckit.modelcheck.verify scope 7`

### Interpret Results

- **✅ PASS** = Property holds within the checked scope (no counterexample found)
- **❌ FAIL** = Property violated (counterexample found in output)

### Optional: Alloy Analyzer GUI (for debugging)

If you need to visually inspect counterexamples or explore the model interactively:

1. **Download Alloy Analyzer**
   - https://alloytools.org/download.html

2. **Load the Model**
   - File → Open → Select `[feature].als`

3. **Execute Check Commands**
   - Click "Execute" next to the check command
   - Green checkmark = PASS, Red X = FAIL

4. **Inspect Counterexamples**
   - Use the graph visualization to understand failures
   - Navigate through atoms and relations

---

## Verification Scope Guidelines

**Scope** refers to the maximum number of instances of each signature:
- `for 3`: Quick verification, good for initial testing (few seconds)
- `for 5`: Standard verification, good balance (several seconds to minutes)
- `for 7`: Thorough verification, high confidence (can take minutes)
- `for 10+`: Very thorough, but can be very slow

**Recommendation**: Start with `for 3`, then increase if passes.

---

## Failure Response Protocol

If a property fails (❌):

1. **Examine Counterexample**
   - Review the counterexample details in verification output
   - For visual inspection, use Alloy Analyzer GUI (see Optional section above)
   - Understand what scenario violates the property

2. **Determine Root Cause**
   - Is the model incorrect? (Fix the `.als` file)
   - Is the specification incomplete? (Update `spec.md`)
   - Is the property too strict? (Refine the assertion)

3. **Take Action**
   - Update model or specification as needed
   - Re-run `/speckit.modelcheck.verify`
   - Results are automatically documented in `verification-log.md`

4. **Mark for Re-verification**
   - Change status to 🔄 after any model changes
   - Re-verify before considering complete

---

## Coverage Assessment

<!--
  ACTION REQUIRED: Update these metrics after each verification session.
  Ensure critical business paths and edge cases are covered by properties.
-->

**Properties defined**: [X]
**Properties verified**: [Y]
**Coverage**: [Y/X]%

### Critical Paths Covered

- [ ] [Critical path 1]
- [ ] [Critical path 2]
- [ ] [Critical path 3]

### Edge Cases Covered

- [ ] [Edge case 1]
- [ ] [Edge case 2]
- [ ] [Edge case 3]

---

## Notes

[Add any additional notes about the verification strategy, known limitations, or future enhancements]

---

## Related Documents

- **Specification**: `../spec.md`
- **Technical Plan**: `../plan.md`
- **Alloy Model**: `./[feature].als`
- **Verification Log**: `./verification-log.md`
