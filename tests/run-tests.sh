#!/usr/bin/env bash
# Run mov2mp4 tests (video conversion + MP3 extraction)
# Usage: ./tests/run-tests.sh [--docker]
# Output goes to outputs/ (gitignored)

set -u

R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
X='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$PROJECT_ROOT/tests/data"
OUTPUT_DIR="$PROJECT_ROOT/outputs"
USE_DOCKER=0

[[ "${1:-}" == "--docker" ]] && USE_DOCKER=1

cd "$PROJECT_ROOT"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

run_test() {
  local name="$1"
  shift
  echo -e "${Y}Test: $name${X}"
  if [[ $USE_DOCKER -eq 1 ]]; then
    docker run --rm \
      -v "$(pwd)/tests/data:/input" \
      -v "$(pwd)/outputs:/output" \
      mov2mp4 "$@" /input /output
  else
    ./mov2mp4 "$@" "$DATA_DIR" "$OUTPUT_DIR"
  fi
}

fail() {
  echo -e "${R}FAIL: $1${X}"
  exit 1
}

# Video conversion (.mov -> .mp4)
run_test "Video conversion (mov to mp4)" || fail "Video conversion failed"
test -f "$OUTPUT_DIR/sample1.mp4" || fail "sample1.mp4 not created"
test -f "$OUTPUT_DIR/サンプル1.mp4" || fail "サンプル1.mp4 not created"
echo -e "  ${G}OK${X} sample1.mp4, サンプル1.mp4"

# MP3 extraction (.mov -> .mp3)
run_test "MP3 extraction (mov to mp3)" -a || fail "MP3 extraction failed"
test -f "$OUTPUT_DIR/sample1.mp3" || fail "sample1.mp3 not created"
test -f "$OUTPUT_DIR/サンプル1.mp3" || fail "サンプル1.mp3 not created"
echo -e "  ${G}OK${X} sample1.mp3, サンプル1.mp3"

# MP3 from MP4: remove sample1.mp3, then run -a on outputs/ (has .mp4 from video conversion)
rm -f "$OUTPUT_DIR/sample1.mp3"
echo -e "${Y}Test: MP3 extraction from MP4${X}"
if [[ $USE_DOCKER -eq 1 ]]; then
  docker run --rm \
    -v "$(pwd)/outputs:/input" \
    -v "$(pwd)/outputs:/output" \
    mov2mp4 -a /input /output
else
  ./mov2mp4 -a "$OUTPUT_DIR" "$OUTPUT_DIR"
fi
test -f "$OUTPUT_DIR/sample1.mp3" || fail "sample1.mp3 from MP4 not created"
echo -e "  ${G}OK${X} MP4 -> MP3"

echo ""
echo -e "${G}All tests passed${X}"
