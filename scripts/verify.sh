#!/bin/bash
# Alloy verification script (host side)
# Execute Alloy verification via Docker
# Location: .specify/scripts/bash/verify.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find project root (where docker-compose.yaml is located)
find_project_root() {
    local dir="$SCRIPT_DIR"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/docker-compose.yaml" ]] || [[ -f "$dir/docker-compose.yml" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo ""
    return 1
}

PROJECT_ROOT="$(find_project_root)"
if [[ -z "$PROJECT_ROOT" ]]; then
    echo -e "${RED}Error: docker-compose.yaml not found${NC}" >&2
    echo "Please place docker-compose.yaml in the project root" >&2
    exit 1
fi

cd "$PROJECT_ROOT"

# Load .env file if exists (for ALLOY_DOCKER_DIR, ALLOY_OUTPUT_DIR etc.)
if [[ -f ".env" ]]; then
    set -a
    source .env
    set +a
fi

# Output directory (can be overridden via ALLOY_OUTPUT_DIR env var)
ALLOY_OUTPUT_DIR="${ALLOY_OUTPUT_DIR:-./alloy-output}"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Show help
show_help() {
    cat << EOF
${GREEN}Alloy Model Checking Tool (Docker version)${NC}

Usage:
  ./verify.sh <alloy-file> [options]

Arguments:
  alloy-file       Path to .als file to verify
                   (e.g., specs/001-purchase/formal/purchase.als)

Options:
  --timeout N      Timeout in seconds (default: 300)
  --format FORMAT  Output format: text, xml (default: text)
  --build          Rebuild Docker image
  --shell          Start Alloy environment shell
  --help           Show this help

Note: Scope is specified in the .als file (e.g., "check PropertyName for 5 but 8 Int")

Examples:
  # Basic verification
  ./verify.sh specs/001-purchase/formal/purchase.als

  # Specify timeout
  ./verify.sh specs/001-purchase/formal/purchase.als --timeout 600

  # Rebuild image and verify
  ./verify.sh specs/001-purchase/formal/purchase.als --build

  # Start debug shell
  ./verify.sh --shell
EOF
}

# Build Docker image
build_image() {
    echo -e "${YELLOW}Building Docker image...${NC}"
    docker compose build alloy-verify
    echo -e "${GREEN}Build complete${NC}"
}

# Start shell
start_shell() {
    echo -e "${YELLOW}Starting Alloy environment shell...${NC}"
    echo "Type 'exit' to quit"
    docker compose run --rm alloy-shell
}

# Default values
BUILD=false
SHELL_MODE=false
ALS_FILE=""
VERIFY_ARGS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --build)
            BUILD=true
            shift
            ;;
        --shell)
            SHELL_MODE=true
            shift
            ;;
        --timeout|--format)
            VERIFY_ARGS="$VERIFY_ARGS $1 $2"
            shift 2
            ;;
        *)
            if [[ -z "$ALS_FILE" ]]; then
                ALS_FILE="$1"
            else
                echo -e "${RED}Error: Multiple .als files specified${NC}" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Shell mode
if [[ "$SHELL_MODE" == true ]]; then
    start_shell
    exit 0
fi

# Check if .als file is specified
if [[ -z "$ALS_FILE" ]]; then
    echo -e "${RED}Error: No .als file specified${NC}" >&2
    echo ""
    show_help
    exit 1
fi

# Check file exists
if [[ ! -f "$ALS_FILE" ]]; then
    echo -e "${RED}Error: File not found: $ALS_FILE${NC}" >&2
    exit 1
fi

# Build if needed
if [[ "$BUILD" == true ]]; then
    build_image
fi

# Check if Docker image exists
if ! docker compose images alloy-verify | grep -q alloy-verify; then
    echo -e "${YELLOW}Docker image not found. Building...${NC}"
    build_image
fi

# Create output directory if it doesn't exist
mkdir -p "$ALLOY_OUTPUT_DIR"

# Run verification
echo -e "${GREEN}Starting Alloy verification...${NC}"
echo ""

# Run verification via Docker
# Convert to relative path under specs/
REL_PATH="${ALS_FILE#specs/}"
docker compose run --rm alloy-verify "/specs/$REL_PATH" $VERIFY_ARGS

EXIT_CODE=$?

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✓ Verification completed successfully${NC}"
else
    echo -e "${RED}✗ Error occurred during verification (exit code: $EXIT_CODE)${NC}"
fi

exit $EXIT_CODE
