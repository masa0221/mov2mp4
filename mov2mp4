#!/usr/bin/env bash
set -u

export LANG="${LANG:-ja_JP.UTF-8}"
export LC_ALL="${LC_ALL:-ja_JP.UTF-8}"

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

mode="safe"
recursive=1
dst="outputs"
dst_specified=0

# Option parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--mode)
      mode="$2"
      shift 2
      ;;
    -r|--recursive)
      recursive=1
      shift
      ;;
    -R|--no-recursive)
      recursive=0
      shift
      ;;
    -o|--output)
      dst="$2"
      dst_specified=1
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options] input(file|directory) [output_directory]"
      echo ""
      echo "Options:"
      echo "  -m, --mode MODE       Conversion mode: fast | safe (default: safe)"
      echo "  -r, --recursive       Recursive search in directory (default)"
      echo "  -R, --no-recursive    Top-level only"
      echo "  -o, --output DIR      Output directory"
      echo "  -h, --help            Show this help"
      echo ""
      echo "Examples:"
      echo "  $0 video.mov                    # Single file, output to outputs/"
      echo "  $0 -m fast ./videos             # Directory conversion in fast mode"
      echo "  $0 -R -o out ./videos            # No recursive, output to out/"
      exit 0
      ;;
    -*)
      echo -e "${R}Unknown option: $1${X}"
      echo "  Use -h for help"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

input="${1:-}"
if [[ $dst_specified -eq 0 && -n "${2:-}" ]]; then
  dst="$2"
fi

if [[ -z "$input" ]]; then
  echo "Usage: $0 [options] input(file|directory) [output_directory]"
  echo "  Use -h for help"
  exit 1
fi

if [[ "$mode" != "fast" && "$mode" != "safe" ]]; then
  echo -e "${R}MODE must be fast or safe (e.g. -m safe)${X}"
  exit 1
fi

if [[ ! -e "$input" ]]; then
  echo -e "${R}Input does not exist: $input${X}"
  exit 1
fi

for cmd in ffmpeg ffprobe; do
  if ! command -v "$cmd" &>/dev/null; then
    echo -e "${R}Error: Required command not found: $cmd${X}"
    echo -e "  Install ffmpeg (e.g. brew install ffmpeg)"
    exit 1
  fi
done

mkdir -p "$dst"
dst="$(cd "$dst" && pwd)"

if [[ -f "$input" ]]; then
  src_base="$(cd "$(dirname "$input")" && pwd)"
  input_file="$src_base/$(basename "$input")"
else
  src_base="$(cd "$input" && pwd)"
  input_file=""
fi

log_dir="$dst/_logs"
mkdir -p "$log_dir"

failed_list="$log_dir/failed.txt"
failed_detail="$log_dir/failed_detail.log"
skipped_list="$log_dir/skipped.txt"
summary="$log_dir/summary.txt"

inputs_txt="$log_dir/inputs.txt"
outputs_txt="$log_dir/outputs.txt"
not_converted_txt="$log_dir/not_converted.txt"

: > "$failed_list"
: > "$failed_detail"
: > "$skipped_list"
: > "$summary"
: > "$inputs_txt"
: > "$outputs_txt"
: > "$not_converted_txt"

ok=0
fail=0
skip=0
missing=0
total=0

# ffmpeg/aac: works with mac ffmpeg (otherwise logged in failed_detail)
# safe: CFR 30fps + yuv420p + High/4.0 + aac (for Vrew)
# fast: try video copy when h264, encode audio to AAC. Fallback to re-encode on copy failure.

convert_one() {
  local f="$1"
  local rel out vcodec errfile

  total=$((total + 1))
  printf '%s\n' "$f" >> "$inputs_txt"

  if [[ ! -f "$f" ]]; then
    missing=$((missing + 1))
    printf 'MISSING: %s\n' "$f" >> "$failed_list"
    return 0
  fi

  rel="${f#$src_base/}"
  rel="${rel#/}"  # Remove leading / (when src_base is /)
  out="$dst/${rel%.*}.mp4"
  mkdir -p "$(dirname "$out")"

  if [[ -f "$out" ]]; then
    skip=$((skip + 1))
    printf '%s\n' "$f" >> "$skipped_list"
    return 0
  fi

  printf "${C}Converting${X}(%s): %s\n" "$mode" "$f"

  errfile="$log_dir/err.$$.txt"
  : > "$errfile"

  vcodec="$(
    ffprobe -nostdin -v error -select_streams v:0 \
      -show_entries stream=codec_name \
      -of default=nw=1:nk=1 "$f" \
      </dev/null 2>>"$errfile" || true
  )"

  if [[ "$mode" == "safe" ]]; then
    # For Vrew: CFR30 / yuv420p / High / level4.0 / AAC(48k)
    ffmpeg -nostdin -hide_banner -y -i "$f" \
      -map 0:v:0 -map 0:a:0? \
      -vf "fps=30,format=yuv420p" \
      -c:v libx264 -profile:v high -level 4.0 -preset veryfast -crf 18 \
      -c:a aac -b:a 192k -ar 48000 -ac 2 \
      -movflags +faststart \
      "$out" </dev/null >>"$errfile" 2>&1
  else
    # fast: try video copy first (when h264). Encode audio to AAC.
    if [[ "$vcodec" == "h264" ]]; then
      ffmpeg -nostdin -hide_banner -y -i "$f" \
        -map 0:v:0 -map 0:a:0? \
        -c:v copy \
        -c:a aac -b:a 192k -ar 48000 -ac 2 \
        -movflags +faststart \
        "$out" </dev/null >>"$errfile" 2>&1

      if [[ $? -ne 0 ]]; then
        # Copy failed → re-encode (without fixed fps)
        ffmpeg -nostdin -hide_banner -y -i "$f" \
          -map 0:v:0 -map 0:a:0? \
          -c:v libx264 -preset veryfast -crf 18 \
          -c:a aac -b:a 192k -ar 48000 -ac 2 \
          -movflags +faststart \
          "$out" </dev/null >>"$errfile" 2>&1
      fi
    else
      ffmpeg -nostdin -hide_banner -y -i "$f" \
        -map 0:v:0 -map 0:a:0? \
        -c:v libx264 -preset veryfast -crf 18 \
        -c:a aac -b:a 192k -ar 48000 -ac 2 \
        -movflags +faststart \
        "$out" </dev/null >>"$errfile" 2>&1
    fi
  fi

  if [[ $? -eq 0 && -f "$out" ]]; then
    ok=$((ok + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL: %s\n' "$f" >> "$failed_list"
    {
      echo "=========="
      echo "MODE     : $mode"
      echo "FAIL FILE: $f"
      echo "OUT FILE : $out"
      echo "--- last 60 lines ---"
      tail -n 60 "$errfile"
      echo
    } >> "$failed_detail"
  fi

  rm -f "$errfile"
}

# Get input file list (pass directly, not via variable, due to null bytes)
if [[ -n "$input_file" ]]; then
  # Single file
  while IFS= read -r -d '' f; do
    [[ -z "$f" ]] && continue
    convert_one "$f"
  done < <(printf '%s\0' "$input_file")
else
  # Directory (top-level only when -R)
  if [[ "$recursive" == "1" ]]; then
    while IFS= read -r -d '' f; do
      [[ -z "$f" ]] && continue
      convert_one "$f"
    done < <(find "$src_base" -type f -name "*.mov" -print0)
  else
    while IFS= read -r -d '' f; do
      [[ -z "$f" ]] && continue
      convert_one "$f"
    done < <(find "$src_base" -maxdepth 1 -type f -name "*.mov" -print0)
  fi
fi

# Output list (enumerate mp4 files, convert back to mov names)
find "$dst" -type f -name "*.mp4" -print0 \
| tr '\0' '\n' \
| sed "s|^$dst/||" \
| sed 's|\.mp4$|.mov|' \
| sort > "$outputs_txt"

# Input list (normalize to relative path, .mov format, sort for comparison with outputs_txt)
sed "s|^$src_base/||" "$inputs_txt" | sed 's|\.[^./]*$|.mov|' | sort > "$inputs_txt.sorted"
mv "$inputs_txt.sorted" "$inputs_txt"

# Not converted (mov in input but not in output)
comm -23 "$inputs_txt" "$outputs_txt" > "$not_converted_txt" || true

{
  echo "MODE: $mode"
  echo "SRC : $src_base"
  echo "DST : $dst"
  echo "TOTAL  : $total"
  echo -e "OK     : ${G}$ok${X}"
  echo -e "SKIP   : ${Y}$skip${X}"
  echo -e "MISSING: ${Y}$missing${X}"
  echo -e "FAIL   : ${R}$fail${X}"
  echo
  echo "skipped       : $skipped_list"
  echo "failed list   : $failed_list"
  echo "failed detail : $failed_detail"
  echo "not converted : $not_converted_txt"
} | tee "$summary"

echo -e "${G}Done${X}"
