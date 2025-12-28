# Verification Properties: [FEATURE_NAME]

**Model File**: `[feature].als`  
**Created**: [DATE]  
**Last Updated**: [DATE]

## Overview

This document tracks the formal properties verified for [FEATURE_NAME]. Each property represents a guarantee about the system's behavior that has been formally specified and checked using Alloy Analyzer.

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

To verify these properties:

1. **Open Alloy Analyzer**
   - Download from: https://alloytools.org/download.html
   - Launch the application

2. **Load the Model**
   - File → Open
   - Select: `specs/[FEATURE_NAME]/formal/[feature].als`

3. **Execute Each Check Command**
   - Find the verification command for each property (listed above)
   - Click "Execute" next to the command in Alloy Analyzer
   - Wait for analysis to complete

4. **Interpret Results**
   - **Green checkmark** = Property PASSED
   - **Red X** = Property FAILED (counterexample shown)

5. **Update This Document**
   - Change status from ⬜ to ✅ or ❌
   - Add verification date
   - Add scope used
   - Add notes about counterexamples if failed

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
   - Alloy Analyzer shows a graph of the counterexample
   - Understand what scenario violates the property

2. **Determine Root Cause**
   - Is the model incorrect? (Fix the `.als` file)
   - Is the specification incomplete? (Update `spec.md`)
   - Is the property too strict? (Refine the assertion)

3. **Take Action**
   - Update model or specification as needed
   - Re-run verification
   - Document the fix in `verification-log.md`

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
