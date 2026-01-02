#!/bin/sh
# Alloy CLI verification script
# Executed inside the container

set -e

ALLOY_JAR="/alloy/alloy.jar"

# Show help
show_help() {
    cat << EOF
Alloy Model Checking Tool

Usage:
  verify-alloy <alloy-file.als> [options]

Options:
  --scope N        Verification scope (default: 5)
  --timeout N      Timeout in seconds (default: 300)
  --format FORMAT  Output format: text, xml (default: text)
  --help           Show this help

Examples:
  verify-alloy /specs/purchase.als
  verify-alloy /specs/purchase.als --scope 7
  verify-alloy /specs/purchase.als --format xml
EOF
}

# Default values
SCOPE=5
TIMEOUT=300
FORMAT="text"
ALS_FILE=""

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --scope)
            SCOPE="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        *)
            if [ -z "$ALS_FILE" ]; then
                ALS_FILE="$1"
            else
                echo "Error: Multiple .als files specified" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if .als file is specified
if [ -z "$ALS_FILE" ]; then
    echo "Error: No .als file specified" >&2
    echo "" >&2
    show_help
    exit 1
fi

# Check file exists
if [ ! -f "$ALS_FILE" ]; then
    echo "Error: File not found: $ALS_FILE" >&2
    exit 1
fi

echo "================================================"
echo "Alloy Model Checking"
echo "================================================"
echo "File: $ALS_FILE"
echo "Scope: $SCOPE"
echo "Timeout: ${TIMEOUT}s"
echo "Output format: $FORMAT"
echo "================================================"
echo ""

# Run Alloy
# Note: Alloy CLI executes all check commands with --check option
if [ "$FORMAT" = "xml" ]; then
    java -jar "$ALLOY_JAR" \
        --timeout "$TIMEOUT" \
        --xml \
        "$ALS_FILE"
else
    # Text format (readable for Claude Code)
    java -jar "$ALLOY_JAR" \
        --timeout "$TIMEOUT" \
        "$ALS_FILE" 2>&1 | \
    awk '
    BEGIN {
        print "Starting verification..."
        in_result = 0
        check_count = 0
    }

    # Detect Check command
    /Executing "Check/ {
        check_count++
        check_name = $0
        gsub(/.*Executing "Check /, "", check_name)
        gsub(/".*/, "", check_name)
        print "\n[Check " check_count ": " check_name "]"
        in_result = 1
        next
    }

    # Detect results
    /No counterexample found/ {
        print "  Result: ✅ PASS (no counterexample)"
        print "  Details: Property holds within specified scope"
        in_result = 0
        next
    }

    /Counterexample found/ {
        print "  Result: ❌ FAIL (counterexample found)"
        in_result = 1
        next
    }

    # Counterexample details
    in_result && /---/ {
        print "  " $0
        next
    }

    in_result && /Skolem/ {
        print "  " $0
        next
    }

    # Error
    /Error:/ {
        print "Error: " $0
    }

    END {
        print "\n================================================"
        print "Verification complete: " check_count " properties checked"
        print "================================================"
    }
    '
fi

echo ""
echo "Verification finished"
