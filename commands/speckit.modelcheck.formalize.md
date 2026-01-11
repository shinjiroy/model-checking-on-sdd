---
description: Generate Alloy model for model checking from technical design. (project)
handoffs:
  - label: Run Verification
    agent: speckit.modelcheck.verify
    prompt: Verify the generated Alloy model
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Single Model Principle

Create **exactly one** Alloy model file per specification:

- File location: `specs/[FEATURE_NAME]/formal/[feature].als`
- Contains all signatures, facts, predicates, and assertions for this feature
- If a model becomes too large (>200 lines), this indicates the spec should be split

## Context Files (Read These First)

1. Constitution: `.specify/memory/constitution.md`
2. Technical Plan: `specs/[FEATURE_NAME]/plan.md`
3. Data Model: `specs/[FEATURE_NAME]/data-model.md` (if exists)
4. API Contracts: `specs/[FEATURE_NAME]/contracts/` (if exists)
5. Research: `specs/[FEATURE_NAME]/research.md` (if exists)

## Outline

### Step 1: Analyze the Technical Design

Read `specs/[FEATURE_NAME]/plan.md` and related files (data-model.md, contracts/) to identify:

**Domain entities**: What are the main entities? (User, Product, Order, Cart, etc.)
**Relationships**: How do entities relate to each other?
**Attributes**: What properties do entities have?
**Constraints**: What rules must always hold? (invariants)
**Operations**: What actions change the system state?
**Properties to verify**: What should we prove? (safety, consistency, no duplicates)

**Integer Value Range Analysis** (CRITICAL):
- Identify all numeric values used in the spec (prices, quantities, percentages, etc.)
- Document the min/max range for each
- Select appropriate Int bit width based on the formula: `2^(n-1) - 1 >= max_value`

| Bit Width | Max Value | Use Case |
|-----------|-----------|----------|
| 4 Int (default) | 7 | Very simple counters |
| 6 Int | 31 | Small quantities |
| 8 Int | 127 | Percentages (0-100) |
| 10 Int | 511 | Larger values |

**String Type Warning**:
- Alloy's String type is extremely limited (no operations, limited comparison)
- Use abstract sig enumerations instead of String for categories/statuses
- Use unique sig atoms for identity values (email, ID)

### Step 2: Check for Size Concerns

If the specification appears to cover multiple independent features (>200 lines of Alloy expected), **STOP and ask**:

```
The specification appears complex and may cover multiple independent features.
This could result in a large Alloy model (>200 lines).

I recommend reviewing whether this spec should be split into smaller, independent features:
- Does it describe multiple features that could be released independently?
- Could different teams work on different parts?
- Can we test parts separately?

Would you like me to:
A. Continue with a single Alloy model (domain is genuinely complex)
B. Suggest how to split the specification
C. Show which parts could become independent specs

Your choice:
```

### Step 3: Create Formal Directory

Create the formal verification directory:

```
specs/[FEATURE_NAME]/formal/
```

### Step 4: Generate Alloy Model

Create `specs/[FEATURE_NAME]/formal/[feature].als` using the template at `.specify/templates/modelcheck-model-template.als`.

**Structure of the model**:

```alloy
/**
 * [FEATURE_NAME] - Alloy Model for Model Checking
 *
 * Generated from: specs/[FEATURE_NAME]/plan.md
 * Date: [DATE]
 * Purpose: [Brief description from plan.md]
 *
 * Integer Range Analysis:
 *   - [field1]: 0-100 → 8 Int required
 *   - [field2]: 0-10 → 4 Int (default) sufficient
 *   - Selected: 8 Int (based on largest required range)
 */

// ============================================================================
// SIGNATURES (Domain Model)
// ============================================================================
// Avoid String type - use abstract sigs for enumerations

abstract sig Status {}
one sig Pending, Active, Completed extends Status {}

sig User {
    balance: Int
} {
    balance >= 0
    balance <= 100  // Explicit bounds prevent overflow issues
}

sig Product {
    price: Int,
    stock: Int
} {
    price >= 0
    stock >= 0
}

// ... additional signatures


// ============================================================================
// FACTS (Global Invariants - Keep Minimal)
// ============================================================================
// WARNING: Over-constraining is a common mistake

fact NoOrphanedData {
    // Example: All orders must belong to a valid user
    all o: Order | o.user in User
}

// ... additional facts


// ============================================================================
// PREDICATES (Operations with Before/After Pattern)
// ============================================================================
// Alloy models snapshots. Use before/after for state transitions.

// ❌ Wrong: Treating parameters as mutable
// pred purchase[u: User, p: Product] { u.balance' = ... }

// ✅ Correct: Use before/after atoms
pred purchase[uBefore, uAfter: User, p: Product] {
    // Precondition
    uBefore.balance >= p.price
    p.stock > 0

    // Postcondition (what changes)
    uAfter.balance = uBefore.balance.minus[p.price]
}

// ... additional predicates


// ============================================================================
// ASSERTIONS (Properties to Verify)
// ============================================================================

assert InventoryConsistency {
    all p: Product | p.stock >= 0
}

assert BalanceIntegrity {
    all u: User | u.balance >= 0
}

// ... additional assertions


// ============================================================================
// VERIFICATION COMMANDS
// ============================================================================
// Int width selected based on value range analysis above

// STEP 1: ALWAYS run first to verify model is satisfiable
run FindExample { some u: User | u.balance > 0 } for 3 but 8 Int

// STEP 2: Check with small scope
check InventoryConsistency for 3 but 8 Int
check BalanceIntegrity for 3 but 8 Int

// STEP 3: Check with larger scope (after step 2 passes)
check InventoryConsistency for 5 but 8 Int
check BalanceIntegrity for 5 but 8 Int

// NOTE: If only small values (0-7), "but 8 Int" can be omitted for speed
```

**Guidelines for model creation**:

1. Use clear, domain-appropriate names
2. Add comments explaining non-obvious constraints
3. Group related elements together
4. Keep the model readable for team review

**Integer Bit Width Selection** (CRITICAL):

| Bit Width | Max Value | Speed | Use Case |
|-----------|-----------|-------|----------|
| 4 Int (default) | 7 | Fastest | Simple counters (0-7) |
| 6 Int | 31 | Fast | Small quantities |
| 8 Int | 127 | Moderate | Percentages (0-100) |
| 10 Int | 511 | Slow | Larger values |
| 12+ Int | 2047+ | Very slow | Avoid if possible |

**Arithmetic Safety**:
- Integer overflow is silent (5+5 = -6 with 4 Int!)
- Always add explicit bounds in sig constraints
- Use `.plus[]` and `.minus[]` functions for clarity

**Scope Selection**:

| Scope | Speed | Confidence | Use Case |
|-------|-------|------------|----------|
| 3 | Fast | Low | Initial testing |
| 5 | Moderate | Medium | Normal verification |
| 7+ | Slow | High | Final validation |

**Run Commands Are Mandatory**:
- ALWAYS include `run` commands before `check` commands
- `run` verifies the model is satisfiable (not over-constrained)
- If `run` returns "no instance", the model has issues

### Step 5: Generate Properties Document

Create `specs/[FEATURE_NAME]/formal/properties.md` listing all properties to verify:

Use template: `.specify/templates/modelcheck-properties-template.md`

Fill in:

- All assertions from the Alloy model
- Verification commands for each
- Description of what each property ensures
- Initial status (unchecked)

### Step 6: Report Completion

After generating all files, inform the user:

```markdown
## Alloy Model Generated ✓

I've created the Alloy model for [FEATURE_NAME]:

**Files created**:
- `formal/[feature].als` - Alloy model (XX lines)
- `formal/properties.md` - Properties to verify (X properties)

**Next steps**:
1. Review the Alloy model for accuracy
2. Use `/speckit.modelcheck.verify` to document results

**Key properties defined**:
- [List key assertions from the model]

**Would you like me to**:
- Explain any part of the Alloy model
- Add additional properties to verify
- Refine the model based on your feedback
```

## Output Files

Generate exactly these files:

1. `specs/[FEATURE_NAME]/formal/[feature].als` - Single Alloy model
2. `specs/[FEATURE_NAME]/formal/properties.md` - Verification checklist

## Important Constraints

- **ONE model file per spec**: Never create multiple `.als` files unless user explicitly requests split
- **No modification of existing files**: Do not touch spec.md, plan.md, tasks.md
- **Self-contained formal directory**: Everything for model checking lives under `formal/`
- **Reference but don't duplicate**: Link to spec.md, don't copy its content
- **Keep it practical**: Focus on verifiable properties, not theoretical perfection

## Error Handling

If the specification lacks necessary details:

```
I need clarification to create an accurate Alloy model:

1. [Specific question about entities/relationships]
2. [Question about constraints]
3. [Question about expected behavior]

These details are needed to properly model the system for model checking in Alloy.
Would you like to update plan.md first, or shall I make reasonable assumptions?
```
