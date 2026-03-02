# movie-converter

[English](README.md)

動画ファイル（.mov）を MP4 に変換するシェルスクリプト。Vrew 用の safe モードと、高速な fast モードを用意。

## 前提条件

- bash
- ffmpeg / ffprobe

## Docker

Docker でも実行できます（Ubuntu ベース）:

```bash
# イメージをビルド
docker build -t movie-converter .
```

ディレクトリを変換（出力は `outputs/` に統一。gitignore 対象）:

```bash
docker run --rm -it -v "$(pwd)/videos:/input" -v "$(pwd)/outputs:/output" movie-converter /input /output
```

オプション付き:

```bash
docker run --rm -it -v "$(pwd)/videos:/input" -v "$(pwd)/outputs:/output" movie-converter -m fast /input /output
```

## 使い方

```bash
./convert.sh [オプション] 入力(ファイル|ディレクトリ) [出力ディレクトリ]
```

### オプション

| オプション | 説明 |
|-----------|------|
| `-m`, `--mode MODE` | 変換モード: `fast` \| `safe`（デフォルト: safe） |
| `-r`, `--recursive` | ディレクトリ内を再帰検索（デフォルト） |
| `-R`, `--no-recursive` | トップ階層のみ検索 |
| `-o`, `--output DIR` | 出力ディレクトリ |
| `-h`, `--help` | ヘルプを表示 |

### 変換モード

- **safe**: CFR 30fps + yuv420p + H.264 High/4.0 + AAC（Vrew 向け）
- **fast**: 可能なら映像コピー、音声のみ AAC エンコード。コピー失敗時は再エンコード

### 使用例

単一ファイルを変換（出力は outputs/）:

```bash
./convert.sh video.mov
```

ディレクトリを変換（再帰検索）:

```bash
./convert.sh ./videos
```

fast モードで変換:

```bash
./convert.sh -m fast ./videos
```

トップ階層のみ、出力先を指定:

```bash
./convert.sh -R -o ./out ./videos
```

単一ファイル、出力先を指定:

```bash
./convert.sh -o ./out video.mov
```

出力先を省略した場合は `outputs/` に出力されます。ログは `出力先/_logs/` に保存されます。

## テスト

### テストデータについて

`tests/data/` に短いテスト用動画が含まれています（git 管理）。英語名（sample1.mov など）と日本語名（サンプル1.mov など）の両方を含み、そのままテストに利用できます。

テスト時の出力先は `outputs/`（gitignore 対象）を指定すること。

### テストの実行

ディレクトリ変換（再帰、出力は outputs/）:

```bash
./convert.sh tests/data
```

トップ階層のみ:

```bash
./convert.sh -R tests/data
```

Docker でテスト:

```bash
docker run --rm -it -v "$(pwd)/tests/data:/input" -v "$(pwd)/outputs:/output" movie-converter /input /output
```

単一ファイル:

```bash
./convert.sh tests/data/sample1.mov
```

### テストデータの再作成

```bash
./tests/setup-testdata.sh [ソースディレクトリ] [秒数]
```

- **ソース省略**: ffmpeg で合成動画を生成（外部依存なし、5秒）
- **ソース指定**: 既存動画から先頭 N 秒を切り出し

ソース指定の例（3秒に変更）:

```bash
./tests/setup-testdata.sh /path/to/videos 3
```

## ライセンス

[LICENSE](LICENSE) を参照してください。
