#!/bin/bash
# MetalForge Build Script
# Builds the Xcode project and provides formatted output for Claude Code

set -o pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Project settings
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_LOG="$PROJECT_DIR/.build/xcodebuild.log"
SCHEME="${1:-MetalForge}"

# Ensure build directory exists
mkdir -p "$PROJECT_DIR/.build"

# Collect errors
ERRORS=""
ERROR_COUNT=0
WARNING_COUNT=0
CURRENT_TARGET=""

echo -e "${BOLD}${BLUE}Building MetalForge...${NC}"
echo -e "${CYAN}Scheme:${NC} $SCHEME"
echo -e "${CYAN}Log:${NC} $BUILD_LOG"
echo ""

# Run xcodebuild and process output
xcodebuild -scheme "$SCHEME" \
    -destination 'platform=macOS' \
    -configuration Debug \
    build \
    2>&1 | tee "$BUILD_LOG" | while IFS= read -r line; do

    # Build target detection
    if [[ "$line" =~ ^===\ BUILD\ TARGET\ ([^[:space:]]+) ]]; then
        CURRENT_TARGET="${BASH_REMATCH[1]}"
        echo -e "${BOLD}${BLUE}[TARGET]${NC} Building target: ${BOLD}$CURRENT_TARGET${NC}"

    # Compile target detection (alternative format)
    elif [[ "$line" =~ ^Compile[[:space:]]+(Swift|C|C\+\+|ObjC) ]]; then
        echo -e "${GREEN}[COMPILE]${NC} ${line}"

    # Swift file compilation
    elif [[ "$line" =~ CompileSwift[[:space:]]+(normal|debug) ]]; then
        echo -e "${GREEN}[SWIFT]${NC} Compiling Swift sources..."

    # Individual file compilation (SwiftCompile)
    elif [[ "$line" =~ SwiftCompile[[:space:]].*[[:space:]]([^/]+\.swift)$ ]]; then
        filename="${BASH_REMATCH[1]}"
        echo -e "${GREEN}  [COMPILE]${NC} $filename"

    # Compiling message from swift driver
    elif [[ "$line" =~ ^Compiling[[:space:]]+([^[:space:]]+)[[:space:]]+(.+\.swift) ]]; then
        echo -e "${GREEN}  [COMPILE]${NC} ${BASH_REMATCH[2]}"

    # Linking
    elif [[ "$line" =~ ^Ld[[:space:]] ]] || [[ "$line" =~ ^Linking[[:space:]] ]]; then
        echo -e "${CYAN}[LINK]${NC} Linking..."

    # Code signing
    elif [[ "$line" =~ ^CodeSign[[:space:]] ]] || [[ "$line" =~ ^Signing[[:space:]] ]]; then
        echo -e "${CYAN}[SIGN]${NC} Code signing..."

    # Copy files
    elif [[ "$line" =~ ^Copy[[:space:]] ]] || [[ "$line" =~ ^CpResource[[:space:]] ]]; then
        echo -e "${CYAN}[COPY]${NC} Copying resources..."

    # Processing Info.plist
    elif [[ "$line" =~ ProcessInfoPlistFile ]] || [[ "$line" =~ ^Processing[[:space:]].*Info\.plist ]]; then
        echo -e "${CYAN}[PLIST]${NC} Processing Info.plist..."

    # Touch (finishing build product)
    elif [[ "$line" =~ ^Touch[[:space:]] ]]; then
        echo -e "${GREEN}[TOUCH]${NC} Finalizing build product..."

    # Errors
    elif [[ "$line" =~ error:[[:space:]] ]] || [[ "$line" =~ ^error: ]]; then
        echo -e "${RED}[ERROR]${NC} $line"
        ERRORS="${ERRORS}\n${line}"
        ((ERROR_COUNT++))

    # Warnings
    elif [[ "$line" =~ warning:[[:space:]] ]] || [[ "$line" =~ ^warning: ]]; then
        echo -e "${YELLOW}[WARNING]${NC} $line"
        ((WARNING_COUNT++))

    # Build succeeded
    elif [[ "$line" =~ "BUILD SUCCEEDED" ]] || [[ "$line" =~ "Build Succeeded" ]]; then
        echo -e "${BOLD}${GREEN}[SUCCESS]${NC} Build succeeded!"

    # Build failed
    elif [[ "$line" =~ "BUILD FAILED" ]] || [[ "$line" =~ "Build Failed" ]]; then
        echo -e "${BOLD}${RED}[FAILED]${NC} Build failed!"

    # Note lines (context for errors) - only show if we've seen errors
    elif [[ "$line" =~ note:[[:space:]] ]] && [[ $ERROR_COUNT -gt 0 ]]; then
        echo -e "${CYAN}  [note]${NC} $line"
    fi
done

# Capture exit code from xcodebuild (through the pipe)
BUILD_RESULT=${PIPESTATUS[0]}

echo ""
echo -e "${BOLD}========================================${NC}"

if [[ $BUILD_RESULT -eq 0 ]]; then
    echo -e "${BOLD}${GREEN}BUILD COMPLETED SUCCESSFULLY${NC}"
else
    echo -e "${BOLD}${RED}BUILD FAILED${NC}"

    # Extract and display all errors from the log
    echo ""
    echo -e "${BOLD}${RED}Error Summary:${NC}"
    echo -e "${RED}----------------------------------------${NC}"
    grep -E "(error:|: error:)" "$BUILD_LOG" | while IFS= read -r error_line; do
        echo -e "${RED}$error_line${NC}"
    done
    echo -e "${RED}----------------------------------------${NC}"
fi

echo ""
echo -e "Full build log: ${CYAN}$BUILD_LOG${NC}"

exit $BUILD_RESULT
