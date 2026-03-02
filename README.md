# movie-converter

[日本語](README.ja.md)

Shell script to convert video files (.mov) to MP4. Safe mode for Vrew and fast mode for quick conversion.

## Requirements

- bash
- ffmpeg / ffprobe

## Docker

Runs on Docker (Ubuntu-based):

```bash
# Build image
docker build -t movie-converter .
```

Convert directory (output to `outputs/`, gitignored):

```bash
docker run --rm -it -v "$(pwd)/videos:/input" -v "$(pwd)/outputs:/output" movie-converter /input /output
```

With options:

```bash
docker run --rm -it -v "$(pwd)/videos:/input" -v "$(pwd)/outputs:/output" movie-converter -m fast /input /output
```

## Usage

```bash
./convert.sh [options] input(file|directory) [output_directory]
```

### Options

| Option | Description |
|--------|-------------|
| `-m`, `--mode MODE` | Conversion mode: `fast` \| `safe` (default: safe) |
| `-r`, `--recursive` | Recursive search in directory (default) |
| `-R`, `--no-recursive` | Top-level only |
| `-o`, `--output DIR` | Output directory |
| `-h`, `--help` | Show help |

### Conversion Modes

- **safe**: CFR 30fps + yuv420p + H.264 High/4.0 + AAC (for Vrew)
- **fast**: Video copy when possible, audio to AAC. Re-encode on copy failure

### Examples

Single file (output to outputs/):

```bash
./convert.sh video.mov
```

Convert directory (recursive):

```bash
./convert.sh ./videos
```

Fast mode:

```bash
./convert.sh -m fast ./videos
```

Top-level only, specify output:

```bash
./convert.sh -R -o ./out ./videos
```

Single file, specify output:

```bash
./convert.sh -o ./out video.mov
```

Output defaults to `outputs/`. Logs are saved in `output/_logs/`.

## Testing

### Test Data

`tests/data/` contains short test videos (git-tracked). Includes both English (sample1.mov) and Japanese (サンプル1.mov) filenames.

Use `outputs/` (gitignored) for test output.

### Run Tests

Directory conversion (recursive, output to outputs/):

```bash
./convert.sh tests/data
```

Top-level only:

```bash
./convert.sh -R tests/data
```

Docker:

```bash
docker run --rm -it -v "$(pwd)/tests/data:/input" -v "$(pwd)/outputs:/output" movie-converter /input /output
```

Single file:

```bash
./convert.sh tests/data/sample1.mov
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
