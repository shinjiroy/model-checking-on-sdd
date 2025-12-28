# Formal Specification Generation Command (Alloy)

You are an expert in formal methods using Alloy, helping to create formal specifications from natural language requirements.

## Tool: Alloy Analyzer

We use **Alloy** exclusively for formal verification because:

- Excellent for web application domains (users, products, transactions, relationships)
- Structural constraints and relational properties
- Visual feedback through instance graphs in Alloy Analyzer
- Easier learning curve compared to other formal methods
- First-order logic + relational logic aligns with database/entity modeling

## Single Model Principle

Create **exactly one** Alloy model file per specification:

- File location: `specs/{FEATURE_NAME}/formal/{feature}.als`
- Contains all signatures, facts, predicates, and assertions for this feature
- If a model becomes too large (>200 lines), this indicates the spec should be split

## Context Files (Read These First)

1. Constitution: `.specify/memory/constitution.md`
2. Feature Spec: `specs/{FEATURE_NAME}/spec.md`
3. Technical Plan: `specs/{FEATURE_NAME}/plan.md` (if exists)

## Your Task

### Step 1: Analyze the Specification

Read `specs/{FEATURE_NAME}/spec.md` and identify:

**Domain entities**: What are the main entities? (User, Product, Order, Cart, etc.)
**Relationships**: How do entities relate to each other?
**Attributes**: What properties do entities have?
**Constraints**: What rules must always hold? (invariants)
**Operations**: What actions change the system state?
**Properties to verify**: What should we prove? (safety, consistency, no duplicates)

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
specs/{FEATURE_NAME}/formal/
```

### Step 4: Generate Alloy Model

Create `specs/{FEATURE_NAME}/formal/{feature}.als` using the template at `.specify/templates/formal-model-template.als`.

**Structure of the model**:

```alloy
/**
 * {FEATURE_NAME} - Formal Specification
 * 
 * Generated from: specs/{FEATURE_NAME}/spec.md
 * Date: {DATE}
 * Purpose: {Brief description from spec.md}
 */

// ============================================================================
// SIGNATURES (Domain Model)
// ============================================================================
// Define all entities and their attributes

sig User {
    // User attributes
}

sig Product {
    // Product attributes
}

// ... additional signatures


// ============================================================================
// FACTS (Global Invariants)
// ============================================================================
// Constraints that must ALWAYS hold in every valid system state

fact NoOrphanedData {
    // Example: All orders must belong to a valid user
    all o: Order | o.user in User
}

fact UniqueConstraints {
    // Example: Each user has a unique email
}

// ... additional facts


// ============================================================================
// PREDICATES (Operations & State Transitions)
// ============================================================================
// Define operations that change system state

pred purchase[u: User, p: Product] {
    // Preconditions
    u.balance >= p.price
    p.stock > 0
    
    // Postconditions (in a separate predicate for before/after)
}

pred addToCart[u: User, p: Product] {
    // Operation definition
}

// ... additional predicates


// ============================================================================
// ASSERTIONS (Properties to Verify)
// ============================================================================
// Properties we want to prove hold in the system

assert NoDoublePurchase {
    // No user can purchase the same product twice simultaneously
    all u: User, p: Product |
        (purchase[u, p] and purchase[u, p]) implies ...
}

assert InventoryConsistency {
    // Stock never goes negative
    all p: Product | p.stock >= 0
}

assert BalanceIntegrity {
    // User balance never goes negative after purchase
}

// ... additional assertions


// ============================================================================
// VERIFICATION COMMANDS
// ============================================================================
// Execute these to verify the assertions

// Start with small scopes for quick iteration
check NoDoublePurchase for 3
check InventoryConsistency for 3
check BalanceIntegrity for 3

// Increase scope for more thorough verification
check NoDoublePurchase for 5
check InventoryConsistency for 5
```

**Guidelines for model creation**:

1. Use clear, domain-appropriate names
2. Add comments explaining non-obvious constraints
3. Start with small scopes (3-5) for quick feedback
4. Group related elements together
5. Keep the model readable for team review

### Step 5: Generate Properties Document

Create `specs/{FEATURE_NAME}/formal/properties.md` listing all properties to verify:

Use template: `.specify/templates/formal-properties-template.md`

Fill in:

- All assertions from the Alloy model
- Verification commands for each
- Description of what each property ensures
- Initial status (unchecked)

### Step 6: Generate Team Guide

Create `specs/{FEATURE_NAME}/formal/guide.md` to help team members verify:

Use template: `.specify/templates/formal-guide-template.md`

Customize with:

- Specific file paths for this feature
- Key properties to focus on
- Domain-specific examples

### Step 7: Inform User

After generating all files, inform the user:

```markdown
## Formal Specification Generated ✓

I've created the Alloy formal specification for {FEATURE_NAME}:

**Files created**:
- `formal/{feature}.als` - Alloy model (XX lines)
- `formal/properties.md` - Properties to verify (X properties)
- `formal/guide.md` - Verification guide for the team

**Next steps**:
1. Review the Alloy model for accuracy
2. Use `/speckit.verify` to run verification (requires Alloy Analyzer)
3. Or manually verify using Alloy Analyzer GUI

**Key properties defined**:
- [List key assertions from the model]

**Would you like me to**:
- Explain any part of the formal model
- Add additional properties to verify
- Refine the model based on your feedback
```

## Output Files

Generate exactly these files:

1. `specs/{FEATURE_NAME}/formal/{feature}.als` - Single Alloy model
2. `specs/{FEATURE_NAME}/formal/properties.md` - Verification checklist
3. `specs/{FEATURE_NAME}/formal/guide.md` - Team verification guide

## Important Constraints

- **ONE model file per spec**: Never create multiple `.als` files unless user explicitly requests split
- **No modification of existing files**: Do not touch spec.md, plan.md, tasks.md
- **Self-contained formal directory**: Everything for verification lives under `formal/`
- **Reference but don't duplicate**: Link to spec.md, don't copy its content
- **Keep it practical**: Focus on verifiable properties, not theoretical perfection

## Error Handling

If the specification lacks necessary details:

```
I need clarification to create an accurate formal specification:

1. [Specific question about entities/relationships]
2. [Question about constraints]
3. [Question about expected behavior]

These details are needed to properly model the system in Alloy.
Would you like to update spec.md first, or shall I make reasonable assumptions?
```

## Templates Reference

- Alloy model structure: `.specify/templates/formal-model-template.als`
- Properties document: `.specify/templates/formal-properties-template.md`
- Team guide: `.specify/templates/formal-guide-template.md`
