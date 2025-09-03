#!/bin/bash

# Run FFglitch natively on macOS (no Docker)
# Usage: ./run-native.sh [effect] [camera] [resolution]

EFFECT=${1:-mv_average}
CAMERA=${2:-0}
RESOLUTION=${3:-1280x720}

echo "🎥 FFglitch Live Webcam (Native macOS)"
echo "====================================="
echo "Effect: $EFFECT"
echo "Camera: $CAMERA" 
echo "Resolution: $RESOLUTION"
echo ""

# Check if binaries exist
if [ ! -f "./ffglitch-0.10.2-macos-aarch64/ffgac" ] || [ ! -f "./ffglitch-0.10.2-macos-aarch64/fflive" ]; then
    echo "❌ FFglitch macOS binaries not found"
    exit 1
fi

# Remove quarantine if needed
if xattr ./ffglitch-0.10.2-macos-aarch64/ffgac 2>/dev/null | grep -q "com.apple.quarantine"; then
    echo "🔓 Removing quarantine from binaries..."
    xattr -r -d com.apple.quarantine ./ffglitch-0.10.2-macos-aarch64/
fi

# Check script exists
SCRIPT_PATH="tutorial/scripts/mpeg4/${EFFECT}.js"
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Script not found: $SCRIPT_PATH"
    echo "Available effects:"
    ls tutorial/scripts/mpeg4/*.js | xargs -n 1 basename | sed 's/\.js$//'
    exit 1
fi

cd ffglitch-0.10.2-macos-aarch64

echo "📺 Starting live glitch effect..."
echo "Press 'q' to quit"
echo ""

# Direct webcam -> glitch -> display (all native)
./ffgac -f avfoundation -framerate 30 -video_size $RESOLUTION -i "$CAMERA" \
    -vcodec mpeg4 -mpv_flags +nopimb+forcemv -qscale:v 1 -fcode 6 \
    -g max -sc_threshold max -f rawvideo pipe: | \
./fflive -i pipe: -s "../$SCRIPT_PATH" -fs

