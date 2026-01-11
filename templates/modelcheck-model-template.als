/**
 * [FEATURE_NAME] - Alloy Model for Model Checking
 *
 * Generated from: specs/[FEATURE_NAME]/plan.md
 * Date: [DATE]
 * Purpose: [BRIEF_DESCRIPTION]
 *
 * Integer Range Analysis:
 *   - [field1]: [min]-[max] → [N] Int required
 *   - [field2]: [min]-[max] → [N] Int (default) sufficient
 *   - Selected: [N] Int (based on largest required range)
 *
 * Bit Width Reference:
 *   4 Int → max 7      (default, fastest)
 *   6 Int → max 31     (fast)
 *   8 Int → max 127    (moderate, good for percentages)
 *   10 Int → max 511   (slow)
 */

// ============================================================================
// SIGNATURES (Domain Model)
// ============================================================================
// IMPORTANT: Avoid String type - use abstract sigs for enumerations
// Alloy's String has no operations (no concat, no substring, limited comparison)

// Example: Status enumeration (instead of String)
abstract sig Status {}
one sig Pending, Active, Completed extends Status {}

// Example: User entity with explicit bounds
sig User {
    balance: Int
} {
    // Inline constraints prevent overflow and invalid states
    balance >= 0
    balance <= 100  // Adjust based on your Integer Range Analysis
}

// Example: Product entity
sig Product {
    price: Int,
    stock: Int
} {
    price >= 0
    price <= 100
    stock >= 0
    stock <= 10
}

// Add additional signatures as needed for your domain
// - Each sig represents an entity type
// - Fields represent relationships or attributes
// - Use multiplicity: one (exactly 1), lone (0 or 1), some (1+), set (0+)
// - Add inline constraints {} for valid ranges


// ============================================================================
// FACTS (Global Invariants - Keep Minimal!)
// ============================================================================
// WARNING: Over-constraining is a common mistake
// Only add facts for truly universal constraints

// Example: No orphaned data
fact NoOrphanedData {
    // Example: All orders must belong to a valid user
    // all o: Order | o.user in User
}

// Example: Uniqueness constraints
fact UniqueConstraints {
    // Example: Each user has a unique email
    // all disj u1, u2: User | u1.email != u2.email
}

// Example: Valid ranges
fact ValidRanges {
    // Example: Prices and stock must be non-negative
    // all p: Product | p.price >= 0 and p.stock >= 0
}

// Add domain-specific facts
// - Express invariants that should never be violated
// - Keep each fact focused on one concept (1 concept = 1 fact)
// - Name facts clearly to explain what they enforce


// ============================================================================
// PREDICATES (Operations with Before/After Pattern)
// ============================================================================
// IMPORTANT: Alloy models snapshots, not transitions!
// Use before/after atoms to model state changes.

// Example: Purchase operation

// ❌ WRONG: Treating parameters as mutable (Alloy has no primed variables!)
// pred purchase[u: User, p: Product] {
//     u.balance' = u.balance - p.price  // This DOES NOT work!
// }

// ✅ CORRECT: Use before/after atoms
pred purchase[uBefore, uAfter: User, p: Product] {
    // Precondition (what must be true before)
    uBefore.balance >= p.price
    p.stock > 0

    // Frame condition (what stays the same)
    // uAfter.email = uBefore.email

    // Postcondition (what changes)
    // Use .minus[] for safe subtraction (still overflows, but clearer)
    uAfter.balance = uBefore.balance.minus[p.price]
}

// Example: Add to cart
pred addToCart[u: User, p: Product] {
    // Define the operation's preconditions
}

// Add predicates for each major operation in your spec
// - Use before/after pattern for state transitions
// - Document preconditions and postconditions clearly


// ============================================================================
// HELPER PREDICATES (Optional)
// ============================================================================
// Utility predicates for complex operations or assertions

// Example: Check if purchase is valid
pred canPurchase[u: User, p: Product] {
    u.balance >= p.price
    p.stock > 0
}


// ============================================================================
// ASSERTIONS (Properties to Verify)
// ============================================================================
// Properties we want to prove hold in the system

// Example: Inventory consistency
assert InventoryConsistency {
    // Stock never goes negative
    all p: Product | p.stock >= 0
}

// Example: Balance integrity
assert BalanceIntegrity {
    // User balance never goes negative
    all u: User | u.balance >= 0
}

// Add assertions for each property you want to verify
// - Focus on safety properties (bad things never happen)
// - Name assertions to clearly describe what's being proven


// ============================================================================
// VERIFICATION COMMANDS
// ============================================================================
// IMPORTANT: Int width selected based on Integer Range Analysis above
// Trade-off: Larger Int = exponentially slower verification

// ========================================
// STEP 1: ALWAYS run first to verify model is satisfiable
// ========================================
// If run returns "no instance", the model is over-constrained!

// Examples

run FindValidInstance {
    some u: User | u.balance > 0
} for 3 but 8 Int

// Add more run commands to explore different scenarios
run FindPurchaseScenario {
    some uBefore, uAfter: User, p: Product | purchase[uBefore, uAfter, p]
} for 3 but 8 Int

// ========================================
// STEP 2: Check with small scope (fast)
// ========================================
check InventoryConsistency for 3 but 8 Int
check BalanceIntegrity for 3 but 8 Int

// ========================================
// STEP 3: Check with larger scope (after step 2 passes)
// ========================================
// Uncomment after initial verification passes
// check InventoryConsistency for 5 but 8 Int
// check BalanceIntegrity for 5 but 8 Int

// ========================================
// Scope Selection Guide:
// ========================================
// Scope 3: Fast, good for initial testing
// Scope 5: Moderate, normal verification
// Scope 7+: Slow, final validation

// NOTE: If only small values (0-7) are used throughout the model,
// "but 8 Int" can be omitted to improve verification speed


// ============================================================================
// NOTES FOR MODEL DEVELOPMENT
// ============================================================================
/*
 * Common Pitfalls to Avoid:
 *
 * 1. INTEGER OVERFLOW (CRITICAL)
 *    - Default 4 Int range is -8 to 7
 *    - 5 + 5 = -6 with 4 Int (silent overflow!)
 *    - Always select appropriate bit width
 *
 * 2. STRING LIMITATIONS
 *    - Alloy String has NO operations (no concat, no substring)
 *    - Use abstract sig enumerations for categories/statuses
 *    - Use unique sig atoms for identity values
 *
 * 3. STATE TRANSITIONS
 *    - Alloy models snapshots, not mutable state
 *    - Use before/after atoms, NOT primed variables
 *    - For complex state machines: open util/ordering[State]
 *
 * 4. EMPTY SET HANDLING
 *    - sum of empty set = 0
 *    - all x: none | false is VACUOUSLY TRUE!
 *
 * 5. MULTIPLICITY CONFUSION
 *    - one: exactly 1 (error if 0 is valid)
 *    - lone: 0 or 1 (can be empty!)
 *    - some: 1 or more
 *    - set: 0 or more (can be empty!)
 *
 * Debugging Tips:
 * - Use "run" commands to visualize example instances
 * - If a check fails, examine the counterexample carefully
 * - Comment out facts temporarily to isolate issues
 * - Start with basic assertions and add complexity incrementally
 */
