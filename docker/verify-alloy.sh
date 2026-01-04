#!/bin/sh
# Alloy CLI verification script
# Executed inside the container

set -e

ALLOY_JAR="/alloy/alloy.jar"
OUTPUT_DIR="/output"

# Show help
show_help() {
    cat << EOF
Alloy Model Checking Tool

Usage:
  verify-alloy <alloy-file.als> [options]

Options:
  --timeout N      Timeout in seconds (default: 600)
  --format FORMAT  Output format: text, xml (default: text)
  --help           Show this help

Note: Scope is specified in the .als file (e.g., "check PropertyName for 5 but 8 Int")

Examples:
  verify-alloy /specs/purchase.als
  verify-alloy /specs/purchase.als --timeout 600
  verify-alloy /specs/purchase.als --format xml
EOF
}

# Default values
TIMEOUT=600
FORMAT="text"
ALS_FILE=""

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
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
echo "Timeout: ${TIMEOUT}s"
echo "Output format: $FORMAT"
echo "Note: Scope is defined in the .als file"
echo "================================================"
echo ""

# Clear output directory
rm -rf "${OUTPUT_DIR:?}"/* 2>/dev/null || true

# Track failed checks for counterexample display
FAILED_CHECKS=""

# Run Alloy with timeout
# Use 'exec' subcommand to execute all check/run commands
# -f: force overwrite of output directory
# -o /output: write to mounted output directory
if [ "$FORMAT" = "xml" ]; then
    timeout "${TIMEOUT}s" java -jar "$ALLOY_JAR" exec \
        -f \
        -o "$OUTPUT_DIR" \
        -t xml \
        "$ALS_FILE"
    exit_code=$?
else
    # Text format (readable for Claude Code)
    timeout "${TIMEOUT}s" java -jar "$ALLOY_JAR" exec \
        -f \
        -o "$OUTPUT_DIR" \
        "$ALS_FILE" 2>&1 | \
    awk '
    BEGIN {
        print "Verification Results:"
        print "================================================"
        check_count = 0
        pass_count = 0
        fail_count = 0
    }

    # Match check commands: "02. check InitialStateValid        0       UNSAT"
    /^[0-9]+\. check/ {
        check_count++
        # Extract command name (field 3)
        cmd_name = $3

        # Check result (last field): UNSAT = no counterexample = PASS
        if ($NF == "UNSAT") {
            print "✅ PASS: " cmd_name
            pass_count++
        } else if ($NF == "SAT") {
            print "❌ FAIL: " cmd_name " (counterexample found)"
            fail_count++
            # Output failed check name for later processing
            print cmd_name > "/tmp/failed_checks.txt"
        } else {
            print "⚠️  UNKNOWN: " cmd_name " (" $NF ")"
        }
        next
    }

    # Match run commands: "00. run InitialOrder 0 1/1 SAT" or "01. run run$2 0 UNSAT"
    /^[0-9]+\. run/ {
        cmd_name = $3
        # SAT means instance found, UNSAT means no instance
        if (/SAT$/ && !/UNSAT$/) {
            print "ℹ️  RUN: " cmd_name " - instance found"
        } else {
            print "ℹ️  RUN: " cmd_name " - no instance"
        }
        next
    }

    # Syntax/Parse errors (not the summary "Errors" line)
    /^Error:/ || /Syntax error/ || /Parse error/ {
        print "🚫 " $0
    }

    END {
        print "================================================"
        print "Summary: " pass_count "/" check_count " checks passed"
        if (fail_count > 0) {
            print "⚠️  " fail_count " check(s) FAILED"
        }
    }
    '
    exit_code=$?
fi

# Check timeout exit status (124 = timeout)
if [ "$exit_code" -eq 124 ]; then
    echo ""
    echo "🚫 ERROR: Verification timed out after ${TIMEOUT}s"
    exit 124
fi

# Display counterexamples for failed checks
RECEIPT_FILE="${OUTPUT_DIR}/receipt.json"
if [ -f "$RECEIPT_FILE" ] && [ -f "/tmp/failed_checks.txt" ]; then
    echo ""
    echo "================================================"
    echo "Counterexamples"
    echo "================================================"

    while IFS= read -r check_name; do
        parse-counterexample "$RECEIPT_FILE" "$check_name"
    done < /tmp/failed_checks.txt

    rm -f /tmp/failed_checks.txt
fi

echo ""
echo "Verification finished"
