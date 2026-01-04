#!/bin/sh
# Parse Alloy receipt.json and display counterexample data
# Usage: parse-counterexample <receipt.json> <check_name>
# Output: Structured counterexample data for LLM agent consumption

set -e

RECEIPT_FILE="$1"
CHECK_NAME="$2"

if [ -z "$RECEIPT_FILE" ] || [ -z "$CHECK_NAME" ]; then
    echo "Usage: parse-counterexample <receipt.json> <check_name>" >&2
    exit 1
fi

if [ ! -f "$RECEIPT_FILE" ]; then
    echo "Error: File not found: $RECEIPT_FILE" >&2
    exit 1
fi

# Check if the command exists and has a solution (counterexample)
HAS_SOLUTION=$(jq -r --arg name "$CHECK_NAME" '.commands[$name].solution // empty | length > 0' "$RECEIPT_FILE" 2>/dev/null)

if [ "$HAS_SOLUTION" != "true" ]; then
    exit 0
fi

echo ""
echo "=== COUNTEREXAMPLE: $CHECK_NAME ==="

# Get the source (assertion being checked)
SOURCE=$(jq -r --arg name "$CHECK_NAME" '.commands[$name].source // "N/A"' "$RECEIPT_FILE")
echo ""
echo "[Assertion]"
echo "$SOURCE"

# Extract skolem values (quantified variables)
SKOLEMS=$(jq -r --arg name "$CHECK_NAME" '
    .commands[$name].solution[0].instances[0].skolems // {} |
    to_entries[] |
    .key + " = " + (
        .value.data |
        if length == 1 then
            .[0] | if type == "array" then .[0] else tostring end
        else
            "[" + (map(if type == "array" then .[0] else tostring end) | join(", ")) + "]"
        end
    )
' "$RECEIPT_FILE" 2>/dev/null)

if [ -n "$SKOLEMS" ]; then
    echo ""
    echo "[Skolem Variables]"
    echo "$SKOLEMS"
fi

# Get instance data
echo ""
echo "[Instance Data]"

INSTANCE_DATA=$(jq -r --arg name "$CHECK_NAME" '
    .commands[$name].solution[0].instances[0].values // {} |
    to_entries[] |
    select(.key | test("^[A-Z]")) |
    select(
        .value | to_entries |
        map(select(.value | length > 0)) |
        length > 0
    ) |
    .key + ":",
    (
        .value | to_entries[] |
        select(.value | length > 0) |
        "  " + .key + ": " + (
            if (.value | type) == "array" then
                if (.value | length) == 1 then
                    (.value[0] | if type == "array" then .[0] else tostring end)
                else
                    "[" + (.value | map(if type == "array" then .[0] else tostring end) | join(", ")) + "]"
                end
            else
                (.value | tostring)
            end
        )
    )
' "$RECEIPT_FILE" 2>/dev/null)

if [ -n "$INSTANCE_DATA" ]; then
    echo "$INSTANCE_DATA"
else
    echo "(empty - no field values in counterexample)"
fi

echo ""
