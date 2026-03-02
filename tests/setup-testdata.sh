#!/usr/bin/env bash
# Create short video clips for testing
# No source: generate synthetic video with ffmpeg (no external dependency)
# With source: extract first N seconds from existing videos

set -u

# Colors (only when stdout is a TTY)
if [[ -t 1 ]]; then
  R='\033[0;31m'
  G='\033[0;32m'
  Y='\033[0;33m'
  C='\033[0;36m'
  X='\033[0m'
else
  R= G= Y= C= X=
fi

if ! command -v ffmpeg &>/dev/null; then
  echo -e "${R}Error: Required command not found: ffmpeg${X}"
  echo "  Install ffmpeg (e.g. brew install ffmpeg)"
  exit 1
fi

SRC="${1:-}"
DURATION="${2:-5}"  # Duration in seconds (default: 5)
DATA_DIR="$(cd "$(dirname "$0")" && pwd)/data"

mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/subdir"  # For recursive search test

generate_synthetic() {
  local out="$1"
  local dur="$2"
  echo -e "${C}Creating${X}: $(basename "$out") (synthetic ${dur}s)"
  ffmpeg -nostdin -y \
    -f lavfi -i "color=c=blue:s=640x360:d=$dur" \
    -f lavfi -i "sine=frequency=1000:duration=$dur" \
    -c:v libx264 -c:a aac -shortest "$out" </dev/null 2>/dev/null
}

if [[ -z "$SRC" ]]; then
  # No source: generate synthetic video (no external dependency)
  echo -e "${C}Creating test data${X} (synthetic video)..."
  echo "  Duration: ${DURATION}s"
  echo "  Output: $DATA_DIR"
  echo ""

  generate_synthetic "$DATA_DIR/sample1.mov" "$DURATION"
  generate_synthetic "$DATA_DIR/sample2.mov" "$DURATION"
  generate_synthetic "$DATA_DIR/サンプル1.mov" "$DURATION"
  generate_synthetic "$DATA_DIR/サンプル2.mov" "$DURATION"
  generate_synthetic "$DATA_DIR/subdir/sample3.mov" "$DURATION"
  generate_synthetic "$DATA_DIR/subdir/sample4.mov" "$DURATION"
  generate_synthetic "$DATA_DIR/subdir/サンプル3.mov" "$DURATION"

else
  # With source: extract from existing videos
  if [[ ! -d "$SRC" ]]; then
    echo -e "${R}Error: Source directory does not exist: $SRC${X}"
    echo "Usage: $0 [source_directory] [seconds]"
    echo "  Omit source to generate synthetic video (no external dependency)"
    exit 1
  fi

  echo -e "${C}Creating test data${X}..."
  echo "  Source: $SRC"
  echo "  Duration: ${DURATION}s"
  echo "  Output: $DATA_DIR"
  echo ""

  count=0
  while IFS= read -r f; do
    [[ $count -ge 4 ]] && break
    rel="${f#$SRC/}"
    rel="${rel#/}"
    if [[ "$rel" == */* ]]; then
      out="$DATA_DIR/subdir/$(basename "$f")"
    else
      out="$DATA_DIR/$(basename "$f")"
    fi
    [[ "$out" == *.mp4 ]] && out="${out%.mp4}.mov"

    if [[ -f "$out" ]]; then
      echo -e "${Y}Skipping${X} (exists): $(basename "$f")"
      continue
    fi

    echo -e "${C}Creating${X}: $(basename "$f") (first ${DURATION}s)"
    if ffmpeg -nostdin -y -i "$f" -t "$DURATION" -c copy "$out" </dev/null 2>/dev/null; then
      count=$((count + 1))
    else
      echo -e "  ${Y}→ Copy failed, trying re-encode${X}"
      ffmpeg -nostdin -y -i "$f" -t "$DURATION" -c:v libx264 -c:a aac "$out" </dev/null 2>/dev/null && count=$((count + 1))
    fi
  done < <(find "$SRC" -type f \( -name "*.mov" -o -name "*.mp4" \) | head -6)
fi

echo ""
echo -e "${G}Done${X}. Test examples (from project root):"
echo "  ./convert.sh tests/data             # Directory (recursive)"
echo "  ./convert.sh -R tests/data           # Directory (top-level only)"
echo "  ./convert.sh tests/data/sample1.mov  # Single file"
