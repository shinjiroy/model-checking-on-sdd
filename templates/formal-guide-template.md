# Formal Verification Guide: [FEATURE_NAME]

**For Team Members**  
**Last Updated**: [DATE]

## Purpose

This guide helps you verify the formal specification for [FEATURE_NAME] using Alloy Analyzer. No prior formal methods experience is required - just follow these steps.

---

## What is Formal Verification?

Formal verification mathematically proves that our system design satisfies specific properties. Think of it as "unit tests for the specification" - we're checking that the design is sound before writing any code.

**Why do this?**
- Catch design flaws early (before implementation)
- Ensure critical properties hold (e.g., no double payments, stock stays consistent)
- Build confidence in complex logic
- Reduce costly bugs in production

---

## Quick Start

### Prerequisites

1. **Install Alloy Analyzer**
   - Download: https://alloytools.org/download.html
   - Version: 6.x or higher recommended
   - Requires: Java 8 or higher

2. **Locate the Model**
   - File: `specs/[FEATURE_NAME]/formal/[feature].als`
   - This is the formal specification you'll be verifying

### Basic Workflow

```
1. Open Alloy Analyzer
2. Load [feature].als
3. Click "Execute" on check commands
4. Review results
5. Report findings
```

---

## Step-by-Step Instructions

### Step 1: Open Alloy Analyzer

Launch the application (icon looks like a stylized "A").

### Step 2: Load the Model

1. Click **File → Open**
2. Navigate to: `specs/[FEATURE_NAME]/formal/[feature].als`
3. The model source code will appear in the editor pane

### Step 3: Understand the Model Structure

The model has several sections (you don't need to understand all the details):

- **Signatures**: Define entities (User, Product, Order, etc.)
- **Facts**: Invariants that must always hold
- **Predicates**: Operations that change state
- **Assertions**: Properties we're verifying
- **Check commands**: These are what you'll execute

Scroll to the bottom to find the `check` commands.

### Step 4: Execute Verification Commands

You'll see commands like:
```alloy
check NoDoublePurchase for 5
check InventoryConsistency for 5
check BalanceIntegrity for 5
```

**For each check command:**

1. Click the **"Execute"** button next to the command
   - This button appears when you hover over the command

2. Wait for analysis (usually a few seconds)
   - Progress bar shows at the bottom
   - Larger scopes (bigger numbers) take longer

3. **Interpret the result:**
   
   **✅ Green Checkmark = PASS**
   ```
   No counterexample found. Assertion may be valid.
   ```
   This means the property holds within the checked scope. Good!
   
   **❌ Red X = FAIL**
   ```
   Counterexample found. Assertion is invalid.
   ```
   This means Alloy found a scenario where the property is violated. 
   This is valuable - it shows a potential problem!

### Step 5: Review Counterexamples (if any failures)

If a check fails:

1. **An instance graph appears**
   - Shows the specific scenario that violates the property
   - Boxes = entities (Users, Products, etc.)
   - Arrows = relationships
   - Numbers = attribute values

2. **Understand the scenario**
   - Read what each box represents
   - Follow the arrows to see relationships
   - Look for what's wrong (negative balance? duplicate orders?)

3. **Click "Next"** to see alternative counterexamples
   - There may be multiple ways the property can fail
   - Review a few to understand the pattern

4. **Take notes**
   - Describe what you see in plain language
   - Example: "Found case where two users buy the same last item, stock becomes -1"

### Step 6: Document Results

Update `formal/properties.md`:

For each property checked:
- Change status: ⬜ → ✅ (pass) or ❌ (fail)
- Add today's date as "Last Verified"
- Add the scope used (e.g., "for 5")
- Add notes about counterexamples (if failed)

---

## Understanding Scope

The number after `for` is the **scope** - how thoroughly to check.

- `for 3`: Quick check (seconds) - good for initial testing
- `for 5`: Standard check (seconds to minutes) - recommended
- `for 7`: Thorough check (minutes) - high confidence
- `for 10+`: Very thorough (can be slow) - use when critical

**Recommendation**: Start with the default scope, usually `for 5`.

---

## Common Results

### All Checks Pass ✅

Great! The design is sound within the checked scope. 

**What this means:**
- No design flaws found in the checked scenarios
- Safe to proceed with implementation
- Consider increasing scope for extra confidence

**Next steps:**
- Document results in properties.md
- Update verification-log.md
- Proceed to implementation with confidence

### Some Checks Fail ❌

Good catch! You've found a potential issue before coding.

**What this means:**
- The design has a flaw or gap
- The counterexample shows a specific problematic scenario
- Needs attention before implementation

**Next steps:**
- Document the counterexample clearly
- Share findings with the team
- Determine if it's:
  - A model error (fix the `.als` file)
  - A spec gap (update `spec.md`)
  - An invalid assumption (refine the assertion)
- Run `/speckit.verify` to get suggestions for fixes
- Re-verify after fixes

---

## Feature-Specific Properties

For [FEATURE_NAME], we're verifying:

### Property 1: [PropertyName]
**What it checks**: [Plain language explanation]  
**Why it matters**: [Business/technical importance]  
**Example violation**: [What a failure would look like]

### Property 2: [PropertyName]
**What it checks**: [Plain language explanation]  
**Why it matters**: [Business/technical importance]  
**Example violation**: [What a failure would look like]

### Property 3: [PropertyName]
**What it checks**: [Plain language explanation]  
**Why it matters**: [Business/technical importance]  
**Example violation**: [What a failure would look like]

---

## Troubleshooting

### Alloy Analyzer won't start
- **Check Java installation**: Alloy requires Java 8+
- **Try downloading again**: Sometimes the download is corrupted
- **Check system requirements**: Alloy works on Windows, Mac, Linux

### Analysis takes forever
- **Reduce scope**: Try `for 3` instead of `for 5`
- **Simplify model**: The model might be over-constrained
- **Check your machine**: Alloy is CPU-intensive

### I don't understand the counterexample
- **Ask for help**: Share a screenshot with the team
- **Try simpler scope**: Use `for 3` for easier-to-understand examples
- **Read the assertion**: Look at what property is being checked
- **Use visualization**: Click through the instance graph slowly

### Model has syntax errors
- **Don't edit the model**: Unless you know Alloy syntax
- **Report to team**: Someone may have partially edited it
- **Regenerate**: Run `/speckit.formalize` again if needed

---

## Getting Help

**If you encounter issues:**

1. **Take a screenshot** of:
   - The Alloy Analyzer window
   - Any error messages
   - The counterexample (if relevant)

2. **Document what you see**:
   - Which check command failed
   - What the scope was
   - Brief description of the counterexample

3. **Ask the team**:
   - Post in [TEAM_CHANNEL]
   - Mention [FORMAL_METHODS_LEAD]
   - Share your screenshots and notes

---

## Tips for Success

✅ **Do:**
- Start with small scopes and work up
- Document your findings clearly
- Ask questions if confused
- Take your time understanding counterexamples
- Celebrate when all checks pass!

❌ **Don't:**
- Skip checks because they seem to take long
- Ignore failures without understanding them
- Edit the model without formal methods knowledge
- Assume passes at small scope mean passes at all scopes

---

## Learning Resources

**New to Alloy?**
- Alloy tutorial: http://alloytools.org/tutorials/online/
- "Software Abstractions" book by Daniel Jackson
- Ask [FORMAL_METHODS_LEAD] for a quick walkthrough

**Want to understand the model better?**
- Use `run` commands to visualize valid instances
- Read comments in the `.als` file
- Discuss with teammates who know formal methods

---

## Summary Checklist

Use this when verifying:

- [ ] Alloy Analyzer installed and working
- [ ] Model file opened: `[feature].als`
- [ ] All `check` commands executed
- [ ] Results recorded (✅ or ❌)
- [ ] Counterexamples documented (if any)
- [ ] `properties.md` updated
- [ ] `verification-log.md` updated
- [ ] Team notified of results
- [ ] Issues raised for any failures

---

## Questions?

Contact: [FORMAL_METHODS_LEAD]  
Documentation: This guide, `properties.md`, `verification-log.md`  
Slack Channel: [TEAM_CHANNEL]

**Remember**: Finding failures is success! It means we caught issues before coding.
