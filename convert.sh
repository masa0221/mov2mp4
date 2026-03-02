#!/usr/bin/env bash
set -u

export LANG="${LANG:-ja_JP.UTF-8}"
export LC_ALL="${LC_ALL:-ja_JP.UTF-8}"

src="${1:-}"
dst="${2:-}"
mode="${MODE:-fast}"  # fast | safe

if [[ -z "$src" || -z "$dst" ]]; then
  echo "使い方: MODE=fast|safe $0 入力ディレクトリ 出力ディレクトリ"
  exit 1
fi

if [[ "$mode" != "fast" && "$mode" != "safe" ]]; then
  echo "MODE は fast か safe を指定してください（例: MODE=safe）"
  exit 1
fi

src="$(cd "$src" && pwd)"
mkdir -p "$dst"
dst="$(cd "$dst" && pwd)"

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

# ffmpeg/aac は mac のffmpegで基本OK（なければ safe/fast ともに失敗ログに出る）
# safe: CFR 30fps + yuv420p + High/4.0 + aac
# fast: 可能なら映像copy、音声aac（Vrewに寄せる）。copy失敗なら再エンコードへフォールバック。

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

  rel="${f#$src/}"
  out="$dst/${rel%.mov}.mp4"
  mkdir -p "$(dirname "$out")"

  if [[ -f "$out" ]]; then
    skip=$((skip + 1))
    printf '%s\n' "$f" >> "$skipped_list"
    return 0
  fi

  printf '変換中(%s): %s\n' "$mode" "$f"

  errfile="$log_dir/err.$$.txt"
  : > "$errfile"

  vcodec="$(
    ffprobe -nostdin -v error -select_streams v:0 \
      -show_entries stream=codec_name \
      -of default=nw=1:nk=1 "$f" \
      </dev/null 2>>"$errfile" || true
  )"

  if [[ "$mode" == "safe" ]]; then
    # Vrewに寄せる: CFR30 / yuv420p / High / level4.0 / AAC(48k)
    ffmpeg -nostdin -hide_banner -y -i "$f" \
      -map 0:v:0 -map 0:a:0? \
      -vf "fps=30,format=yuv420p" \
      -c:v libx264 -profile:v high -level 4.0 -preset veryfast -crf 18 \
      -c:a aac -b:a 192k -ar 48000 -ac 2 \
      -movflags +faststart \
      "$out" </dev/null >>"$errfile" 2>&1
  else
    # fast: まず映像copyを試す（h264のとき）。音声はAACへ。
    if [[ "$vcodec" == "h264" ]]; then
      ffmpeg -nostdin -hide_banner -y -i "$f" \
        -map 0:v:0 -map 0:a:0? \
        -c:v copy \
        -c:a aac -b:a 192k -ar 48000 -ac 2 \
        -movflags +faststart \
        "$out" </dev/null >>"$errfile" 2>&1

      if [[ $? -ne 0 ]]; then
        # copy失敗 → 再エンコード（ただしfps固定はしない）
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

# find の入力を壊さない（ffmpeg/ffprobeはnostdin + /dev/null）
while IFS= read -r -d '' f; do
  convert_one "$f"
done < <(find "$src" -type f -name "*.mov" -print0)

# 出力一覧（出力側のmp4を列挙してmov名に戻す）
find "$dst" -type f -name "*.mp4" -print0 \
| tr '\0' '\n' \
| sed "s|^$dst/||" \
| sed 's|\.mp4$|.mov|' \
| sort > "$outputs_txt"

# 入力一覧（相対にしてソート）
sed "s|^$src/||" "$inputs_txt" | sort > "$inputs_txt.sorted"
mv "$inputs_txt.sorted" "$inputs_txt"

# 未変換（入力にあって出力にないmov）
comm -23 "$inputs_txt" "$outputs_txt" > "$not_converted_txt" || true

{
  echo "MODE: $mode"
  echo "SRC : $src"
  echo "DST : $dst"
  echo "TOTAL  : $total"
  echo "OK     : $ok"
  echo "SKIP   : $skip"
  echo "MISSING: $missing"
  echo "FAIL   : $fail"
  echo
  echo "skipped       : $skipped_list"
  echo "failed list   : $failed_list"
  echo "failed detail : $failed_detail"
  echo "not converted : $not_converted_txt"
} | tee "$summary"

echo "完了"
