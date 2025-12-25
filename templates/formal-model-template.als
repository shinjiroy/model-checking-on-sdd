/**
 * {FEATURE_NAME} - Formal Specification
 * 
 * Generated from: specs/{FEATURE_NAME}/spec.md
 * Date: {DATE}
 * Purpose: {BRIEF_DESCRIPTION}
 * 
 * This Alloy model formalizes the requirements specified in spec.md.
 * It defines the system's structure, constraints, and properties to verify.
 */

// ============================================================================
// SIGNATURES (Domain Model)
// ============================================================================
// Define all entities and their attributes
// These represent the core objects in your domain

// Example: User entity
sig User {
    // Define user attributes
    // Example: email: one String,
    //          balance: one Int
}

// Example: Product entity
sig Product {
    // Define product attributes
    // Example: price: one Int,
    //          stock: one Int
}

// Add additional signatures as needed for your domain
// - Each sig represents an entity type
// - Fields represent relationships or attributes
// - Use multiplicity: one, lone, some, set


// ============================================================================
// FACTS (Global Invariants)
// ============================================================================
// Constraints that must ALWAYS hold in every valid system state
// These are non-negotiable rules about your domain

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
// - Keep each fact focused on one concept
// - Name facts clearly to explain what they enforce


// ============================================================================
// PREDICATES (Operations & State Transitions)
// ============================================================================
// Define operations that change system state
// These represent actions users or systems can take

// Example: Purchase operation
pred purchase[u: User, p: Product] {
    // Preconditions (what must be true before the operation)
    // Example:
    // u.balance >= p.price
    // p.stock > 0
    
    // Postconditions would typically be in a separate predicate
    // showing the before/after states
}

// Example: Add to cart
pred addToCart[u: User, p: Product] {
    // Define the operation's preconditions and effects
}

// Add predicates for each major operation in your spec
// - Use clear, domain-appropriate names
// - Document preconditions and postconditions
// - Consider using before/after state predicates for complex operations


// ============================================================================
// HELPER PREDICATES (Optional)
// ============================================================================
// Utility predicates that help define more complex operations or assertions

// Example: Check if purchase is valid
pred canPurchase[u: User, p: Product] {
    // Helper logic
}


// ============================================================================
// ASSERTIONS (Properties to Verify)
// ============================================================================
// Properties we want to prove hold in the system
// These are the formal guarantees we're checking

// Example: No double purchase
assert NoDoublePurchase {
    // Formalize: A user cannot purchase the same product twice simultaneously
    // Example:
    // all u: User, p: Product |
    //     not (purchase[u, p] and purchase[u, p])
}

// Example: Inventory consistency
assert InventoryConsistency {
    // Formalize: Stock never goes negative
    // Example:
    // all p: Product | p.stock >= 0
}

// Example: Balance integrity
assert BalanceIntegrity {
    // Formalize: User balance never goes negative after valid operations
    // Example:
    // all u: User | u.balance >= 0
}

// Add assertions for each property you want to verify
// - Focus on safety properties (bad things never happen)
// - Consider liveness properties (good things eventually happen)
// - Name assertions to clearly describe what's being proven


// ============================================================================
// VERIFICATION COMMANDS
// ============================================================================
// Execute these commands in Alloy Analyzer to verify the assertions
// Start with small scopes (3-5) for quick feedback
// Increase scope for more thorough verification (but slower)

// Verify with small scope (fast, good for initial testing)
check NoDoublePurchase for 3
check InventoryConsistency for 3
check BalanceIntegrity for 3

// Verify with larger scope (slower, more thorough)
// Uncomment these after initial verification passes
// check NoDoublePurchase for 5
// check InventoryConsistency for 5
// check BalanceIntegrity for 5

// For very thorough verification (can be slow)
// check NoDoublePurchase for 7
// check InventoryConsistency for 7


// ============================================================================
// EXAMPLE PREDICATES (Optional - for exploring the model)
// ============================================================================
// These predicates help you understand the model by showing example instances
// Not for verification, but for exploration and debugging

// Example: Show a valid purchase scenario
pred exampleValidPurchase {
    some u: User, p: Product | purchase[u, p]
}

// To visualize: Execute "run exampleValidPurchase for 3" in Alloy Analyzer
// This shows you what a valid purchase looks like in your model


// ============================================================================
// NOTES FOR MODEL DEVELOPMENT
// ============================================================================
/*
 * Development Guidelines:
 * 
 * 1. Start Simple: Begin with core entities and basic relationships
 * 2. Add Constraints: Add facts one at a time, verifying after each
 * 3. Define Operations: Model key operations from spec.md
 * 4. Write Assertions: Formalize the properties you want to guarantee
 * 5. Verify: Run checks with small scope first (for 3)
 * 6. Iterate: Fix issues, refine model, re-verify
 * 7. Increase Scope: Once passing at small scope, try larger (for 5, for 7)
 * 
 * Common Pitfalls:
 * - Over-constraining: Adding too many facts can make the model unsatisfiable
 * - Under-constraining: Too few facts may allow invalid states
 * - Scope too large: Start small (for 3) and increase gradually
 * - Complex predicates: Break down into smaller helper predicates
 * 
 * Debugging Tips:
 * - Use "run" commands to visualize example instances
 * - If a check fails, examine the counterexample carefully
 * - Comment out facts temporarily to isolate issues
 * - Start with basic assertions and add complexity incrementally
 */
