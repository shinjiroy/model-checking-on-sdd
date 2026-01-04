// Simple test model
module SimpleTest

sig User {
  balance: Int
} {
  balance >= 0
}

// Should find an instance
run FindUser {
  some u: User | u.balance > 0
} for 3

// Should pass (no counterexample)
assert BalanceNonNegative {
  all u: User | u.balance >= 0
}

check BalanceNonNegative for 3
