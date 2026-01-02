# Model Checking Verification Log: [FEATURE_NAME]

This document records all model checking verification sessions for [FEATURE_NAME]. Each verification run is logged here with results and actions taken.

---

## Initial Setup

**Model Created**: [DATE]  
**Initial Model File**: `[feature].als`  
**Properties Defined**: [X]  
**Verification Tool**: Alloy Analyzer

---

## Verification Sessions

<!--
  ACTION REQUIRED: Log each verification session using the template below.
  Copy the template, fill in the details, and append to the Historical Sessions section.
  Sessions should be logged in reverse chronological order (newest first).
-->

---

### Session Template

```markdown
---
## Verification Session: [TIMESTAMP]

**Verifier**: [USER_NAME or "Team Member"]
**Model Version**: [GIT_COMMIT_HASH or DATE]
**Alloy Analyzer Version**: [VERSION]
**Scope Used**: for [N]

### Results Summary

| Property | Status | Scope | Duration |
|----------|--------|-------|----------|
| PropertyName1 | ✅ PASS | for 5 | 3s |
| PropertyName2 | ❌ FAIL | for 5 | 5s |
| PropertyName3 | ✅ PASS | for 5 | 2s |

**Overall**: X/Y properties verified successfully

### Passed Properties

✅ **PropertyName1**
- No counterexample found
- Verified within scope

✅ **PropertyName3**  
- No counterexample found
- Verified within scope

### Failed Properties

❌ **PropertyName2**

**Counterexample Description**:
[Describe the scenario that violates the property in plain language]

**Instance Details**:
[Key details from the counterexample graph]
- Entity1: attribute = value
- Entity2: attribute = value
- Relationship: ...

**Root Cause Analysis**:
[Analysis of why this violation occurred]

**Proposed Fix**:
[Description of how to address the issue]

### Actions Taken

- [ ] Action item 1
- [ ] Action item 2
- [ ] Schedule re-verification

### Notes

[Any additional observations, concerns, or decisions]
```

---

## Historical Sessions

<!--
  ACTION REQUIRED: Append new verification sessions here.
  Copy the Session Template above, fill in the details, and paste here.
-->

[Verification sessions will be appended here as they occur]

---

## Verification Metrics

### Current Status

- **Total Properties**: [X]
- **Verified (Pass)**: [Y]
- **Failed**: [Z]
- **Not Yet Verified**: [W]
- **Success Rate**: [Y/X]%

### Verification Coverage

- **Last Full Verification**: [DATE]
- **Highest Scope Tested**: for [N]
- **Average Verification Time**: [X] seconds

---

## Issue Tracking

<!--
  ACTION REQUIRED: Track issues discovered during verification.
  Move issues from Open to Resolved when fixed and re-verified.
-->

### Open Issues

[List any open issues discovered during verification]

### Resolved Issues

[List issues that have been fixed and re-verified]

---

## Notes

[General notes about the verification process, model evolution, or lessons learned]
