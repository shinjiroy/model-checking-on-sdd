/**
 * [FEATURE_NAME] - Alloy Model for Model Checking
 *
 * Generated from: specs/[FEATURE_NAME]/plan.md
 * Date: [DATE]
 * Purpose: [BRIEF_DESCRIPTION]
 *
 * Integer Range Analysis:
 *   - [field1]: [min]-[max] → [N] Int required
 *   - Selected: [N] Int (based on largest required range)
 */

// ============================================================================
// SIGNATURES (Domain Model)
// ============================================================================

// Add signatures here

// ============================================================================
// FACTS (Global Invariants - Keep Minimal)
// ============================================================================

// Add facts here

// ============================================================================
// PREDICATES (Operations with Before/After Pattern)
// ============================================================================

// Add predicates here

// ============================================================================
// ASSERTIONS (Properties to Verify)
// ============================================================================

// Add assertions here

// ============================================================================
// VERIFICATION COMMANDS
// ============================================================================

// STEP 1: ALWAYS run first to verify model is satisfiable
run FindExample { } for 3 but [N] Int

// STEP 2: Check with small scope
// check [AssertionName] for 3 but [N] Int

// STEP 3: Check with larger scope (after step 2 passes)
// check [AssertionName] for 5 but [N] Int
