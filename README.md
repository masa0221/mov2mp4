# mov2mp4

[日本語](README.ja.md)

Shell script to convert video files (.mov, .mp4) to MP4 or extract audio to MP3. Safe mode for Vrew and fast mode for quick conversion.

## Requirements

- bash
- ffmpeg / ffprobe

## Docker

Runs on Docker (Ubuntu-based):

```bash
# Build image
docker build -t mov2mp4 .
```

Convert directory (output to `outputs/`, gitignored):

```bash
docker run --rm -it -v "$(pwd)/videos:/input" -v "$(pwd)/outputs:/output" mov2mp4 /input /output
```

With options:

```bash
docker run --rm -it -v "$(pwd)/videos:/input" -v "$(pwd)/outputs:/output" mov2mp4 -m fast /input /output
docker run --rm -it -v "$(pwd)/videos:/input" -v "$(pwd)/outputs:/output" mov2mp4 -a /input /output
```

## Usage

```bash
./mov2mp4 [options] input(file|directory) [output_directory]
```

### Options

| Option | Description |
|--------|-------------|
| `-a`, `--audio-only` | Extract audio to MP3 (from .mov/.mp4) |
| `-m`, `--mode MODE` | Conversion mode: `fast` \| `safe` (default: safe) |
| `-r`, `--recursive` | Recursive search in directory (default) |
| `-R`, `--no-recursive` | Top-level only |
| `-o`, `--output DIR` | Output directory |
| `-h`, `--help` | Show help |

### Conversion Modes

- **video** (default): Convert .mov to MP4
  - **safe**: CFR 30fps + yuv420p + H.264 High/4.0 + AAC (for Vrew)
  - **fast**: Video copy when possible, audio to AAC. Re-encode on copy failure
- **audio** (`-a`): Extract audio to MP3 from .mov or .mp4 (192k, 48kHz, stereo)

### Examples

Single file (output to outputs/):

```bash
./mov2mp4 video.mov
```

Extract MP3 from video:

```bash
./mov2mp4 -a video.mp4
./mov2mp4 -a video.mov
./mov2mp4 -a ./videos
```

Convert directory (recursive):

```bash
./mov2mp4 ./videos
```

Fast mode:

```bash
./mov2mp4 -m fast ./videos
```

Top-level only, specify output:

```bash
./mov2mp4 -R -o ./out ./videos
```

Single file, specify output:

```bash
./mov2mp4 -o ./out video.mov
```

Output defaults to `outputs/`. Logs are saved in `output/_logs/`.

## Testing

### Test Data

`tests/data/` contains short test videos (git-tracked). Includes both English (sample1.mov) and Japanese (サンプル1.mov) filenames.

Use `outputs/` (gitignored) for test output.

### Run Tests

Automated test script (video conversion + MP3 extraction):

```bash
./tests/run-tests.sh
./tests/run-tests.sh --docker
```

Manual tests:

```bash
./mov2mp4 tests/data
./mov2mp4 -a tests/data
./mov2mp4 -R tests/data
```

Docker:

```bash
docker run --rm -it -v "$(pwd)/tests/data:/input" -v "$(pwd)/outputs:/output" mov2mp4 /input /output
docker run --rm -it -v "$(pwd)/tests/data:/input" -v "$(pwd)/outputs:/output" mov2mp4 -a /input /output
```

Single file:

```bash
./mov2mp4 tests/data/sample1.mov
./mov2mp4 -a tests/data/sample1.mov
```

### Regenerate Test Data

```bash
./tests/setup-testdata.sh [source_directory] [seconds]
```

- **No source**: Generate synthetic video (no external dependency, 5s)
- **With source**: Extract first N seconds from existing videos

Example with source (3 seconds):

```bash
./tests/setup-testdata.sh /path/to/videos 3
```

## License

See [LICENSE](LICENSE).
