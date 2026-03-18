#!/usr/bin/env bash
# build_plugin.sh
# Improved script to compile entire project and package one plugin as JAR

set -euo pipefail

# ────────────────────────────────────────────────
# CONFIGURATION
# ────────────────────────────────────────────────

SRC_ROOT="src"
BIN_ROOT="bin"
PLUGINS_DIR="plugins"

# Where plugin source files live
PLUGIN_PACKAGE="buttonstuff/plugins"

# ────────────────────────────────────────────────
# USAGE
# ────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: $0 <ClassName> [optional-url]

Examples:
  $0 GreenButton
  $0 DrawingButton
  $0 GreenButton https://example.com

This script:
  1. Cleans and compiles the entire project
  2. Packages the requested plugin class as a JAR
  3. Places JAR in $PLUGINS_DIR/
EOF
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

CLASS_NAME="$1"
# Optional second argument currently unused, but kept for compatibility
# EXTRA_URL="${2:-https://example.com}"

SRC_FILE="$SRC_ROOT/$PLUGIN_PACKAGE/${CLASS_NAME}.java"
CLASS_RELATIVE="buttonstuff/plugins/${CLASS_NAME}.class"
JAR_FILE="$PLUGINS_DIR/${CLASS_NAME}.jar"

# ────────────────────────────────────────────────
# CHECKS
# ────────────────────────────────────────────────

if [[ ! -f "$SRC_FILE" ]]; then
    echo "❌ Source file not found: $SRC_FILE"
    exit 1
fi

# ────────────────────────────────────────────────
# PREPARE
# ────────────────────────────────────────────────

echo "========================================"
echo "Building plugin: $CLASS_NAME"
echo "========================================"

echo "→ Cleaning previous build..."
rm -rf "$BIN_ROOT" 2>/dev/null || true
mkdir -p "$BIN_ROOT" "$PLUGINS_DIR"

# ────────────────────────────────────────────────
# COMPILE FULL PROJECT
# ────────────────────────────────────────────────

echo "→ Compiling entire project..."

echo "→ Compiling entire project..."

javac -d "$BIN_ROOT" -sourcepath "$SRC_ROOT" \
  "$SRC_ROOT/button_interfaces/IButton.java" \
  "$SRC_ROOT/button_interfaces/DButton.java" \
  "$SRC_ROOT/buttonstuff/app/URLButtonDemo.java" \
  "$SRC_ROOT/buttonstuff/app/utilities/ButtonAdder.java" \
  "$SRC_ROOT/buttonstuff/browser/BrowserOps.java" \
  "$SRC_ROOT/buttonstuff/buttons/ParentButton.java" \
  "$SRC_ROOT/buttonstuff/buttons/BruceSpringsteenButton.java" \
  "$SRC_ROOT/buttonstuff/buttons/ChildMethodVisibilityButton.java" \
  "$SRC_ROOT/buttonstuff/buttons/DeepPurpleButton.java" \
  "$SRC_ROOT/buttonstuff/buttons/TaylorSwiftButton.java" \
  "$SRC_ROOT/buttonstuff/loader/PluginLoader.java" \
  "$SRC_ROOT/buttonstuff/plugins/GreenButton.java" \
  "$SRC_ROOT/buttonstuff/plugins/StudentButtonTemplate.java" \
  "$SRC_ROOT/buttonstuff/plugins/DrawingButton.java" 2>&1
  
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Compilation failed"
    echo ""
    echo "Common reasons:"
    echo "  • 'src.' is still in some package declarations"
    echo "  • Wrong import statements (e.g. import src.buttonstuff...)"
    echo "  • Missing .java files in one of the folders above"
    echo ""
    echo "Run this command manually and look at the first error:"
    echo "  javac -d bin -sourcepath src src/**/*.java"
    exit 1
fi

echo "→ Full project compiled successfully"

# ────────────────────────────────────────────────
# CREATE JAR
# ────────────────────────────────────────────────

echo "→ Creating JAR: $JAR_FILE"

jar cf "$JAR_FILE" -C "$BIN_ROOT" "$CLASS_RELATIVE" 2>&1

if [ -f "$JAR_FILE" ]; then
    echo ""
    echo "✓ Success!"
    echo "  Plugin JAR created: $JAR_FILE"
    echo ""
    echo "To test:"
    echo "  java -cp bin buttonstuff.app.URLButtonDemo"
else
    echo ""
    echo "❌ Failed to create JAR file"
    exit 1
fi