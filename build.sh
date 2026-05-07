#!/usr/bin/env bash
set -e

GAME_NAME="wambam"
LOVE_WIN_DIR="/mnt/c/Program Files/LOVE"
OUTPUT_DIR="$(pwd)/release"

echo "Building LÖVE game: $GAME_NAME"
echo "Output directory: $OUTPUT_DIR"
echo

# -------------------------------
# 1. Build .love file
# -------------------------------
echo "[1/3] Creating $GAME_NAME.love..."

# Zip *contents* of current directory, not the folder itself
zip -9 -r "$OUTPUT_DIR/$GAME_NAME.zip" . -x "build.sh" "*.git*" "*__pycache__*" "*.DS_Store"
mv "$OUTPUT_DIR/$GAME_NAME.zip" "$OUTPUT_DIR/$GAME_NAME.love"

echo "Created $GAME_NAME.love"
echo

# -------------------------------
# 2. Build Windows EXE
# -------------------------------
echo "[2/3] Building Windows EXE..."

WIN_EXE="$OUTPUT_DIR/${GAME_NAME}.exe"

# Combine love.exe + game.love
cat "$LOVE_WIN_DIR/love.exe" "$OUTPUT_DIR/$GAME_NAME.love" > "$WIN_EXE"

# Copy required DLLs
cp "$LOVE_WIN_DIR"/*.dll "$OUTPUT_DIR/"

echo "Created Windows build: $WIN_EXE"
echo

# -------------------------------
# 3. Build Linux executable
# -------------------------------
echo "[3/3] Building Linux executable..."

# Find Linux love binary (WSL usually has it installed)
LOVE_LINUX_BIN="$(command -v love)"

if [ -z "$LOVE_LINUX_BIN" ]; then
    echo "Error: 'love' not found in PATH. Install LÖVE on WSL/Linux."
    exit 1
fi

LINUX_BIN="$OUTPUT_DIR/$GAME_NAME"

cat "$LOVE_LINUX_BIN" "$OUTPUT_DIR/$GAME_NAME.love" > "$LINUX_BIN"
chmod +x "$LINUX_BIN"

echo "Created Linux build: $LINUX_BIN"
echo

echo "All builds complete!"
echo "Files created:"
echo " - $GAME_NAME.love"
echo " - $GAME_NAME.exe"
echo " - $GAME_NAME (Linux binary)"
echo " - DLLs for Windows build"

