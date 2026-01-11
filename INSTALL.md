# Spec Kit モデル検査拡張 - インストールガイド

**対応環境**: macOS, Linux, WSL2

---

## 目次

1. [前提条件](#前提条件)
2. [インストール手順](#インストール手順)
3. [動作確認](#動作確認)
4. [ファイル構成](#ファイル構成)
5. [トラブルシューティング](#トラブルシューティング)

---

## 前提条件

### 必須

1. **Spec Kitがインストール済み**
   - プロジェクトに`.specify/`ディレクトリが存在
   - `/speckit.specify`などの基本コマンドが動作

2. **Docker環境**
   - **macOS**: Docker Desktop for Mac
   - **Linux**: Docker Engine + Docker Compose
   - **Windows**: WSL2 + Docker Desktop

3. **確認方法**

   ```bash
   # Dockerバージョン確認
   docker --version
   # 出力例: Docker version 24.0.0, build xxxxx
   
   # Docker Composeバージョン確認
   docker compose --version
   # 出力例: Docker Compose version v2.20.0
   ```

---

## インストール手順

### ステップ1: パッケージのダウンロード

```bash
# パッケージを任意の場所にダウンロード・展開
cd ~/Downloads
unzip model-checking-on-sdd.zip
cd model-checking-on-sdd
```

### ステップ2: Spec Kitプロジェクトへのコピー

```bash
# Spec Kitプロジェクトのルートに移動
cd /path/to/your/speckit-project

# パッケージのパスを環境変数に設定(任意)
FORMAL_PKG=~/Downloads/model-checking-on-sdd
```

#### 2.1 コマンドファイルをコピー（Claude Codeの場合）

```bash
# commands/ → .claude/commands/
mkdir -p .claude/commands
cp -r ${FORMAL_PKG}/commands/* .claude/commands/

# 確認
ls .claude/commands/
# 期待される出力: ... speckit.modelcheck.formalize.md speckit.modelcheck.verify.md ...
```

> **Note**: Cursorなど他のエージェントを使用する場合は、各エージェントのコマンド配置先に合わせてください。

#### 2.2 テンプレートファイルをコピー

```bash
# templates/ → .specify/templates/
cp -r ${FORMAL_PKG}/templates/* .specify/templates/

# 確認
ls .specify/templates/ | grep modelcheck
# 期待される出力:
# modelcheck-model-template.als
# modelcheck-properties-template.md
# modelcheck-verification-log-template.md
```

#### 2.3 ドキュメントをコピー

```bash
# ドキュメントディレクトリを作成(存在しない場合)
mkdir -p .specify/docs

# GUIDE.md → .specify/docs/
cp ${FORMAL_PKG}/GUIDE.md .specify/docs/

# 確認
ls .specify/docs/
# 期待される出力: ... GUIDE.md ...
```

#### 2.4 Docker環境をコピー

```bash
# docker/ → ./docker/alloy/ (既存のdocker/と衝突しない)
mkdir -p docker/alloy
cp -r ${FORMAL_PKG}/docker/* docker/alloy/

# docker-compose.yaml → ./
# 注意: 既存のdocker-compose.yamlがある場合はマージが必要
cp ${FORMAL_PKG}/docker-compose.yaml ./

# .env.example → ./（カスタマイズ用）
cp ${FORMAL_PKG}/.env.example ./

# verify.sh → .specify/scripts/bash/
mkdir -p .specify/scripts/bash
cp ${FORMAL_PKG}/scripts/verify.sh .specify/scripts/bash/

# 実行権限を付与
chmod +x .specify/scripts/bash/verify.sh
```

**カスタマイズ:**

docker/alloy/ 以外に配置する場合:

```bash
# .envファイルを作成してパスを変更
cp .env.example .env
# ALLOY_DOCKER_DIR を編集
```

### ステップ3: Dockerイメージのビルド

```bash
# プロジェクトルートで実行
docker compose build alloy-verify
```

**ビルド中の出力例:**

```text
[+] Building 45.2s (8/8) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 485B
 => [internal] load .dockerignore
 => [1/3] FROM docker.io/library/eclipse-temurin:17-jdk-alpine
 => [2/3] WORKDIR /alloy
 => [3/3] RUN apk add --no-cache wget && ...
 => exporting to image
 => => exporting layers
 => => writing image sha256:...
 => => naming to docker.io/library/model-checking-on-sdd_alloy-verify
```

**所要時間**: 初回ビルドは3-5分程度(Alloy JARをダウンロード)

---

## 動作確認

### テスト1: ヘルプ表示

```bash
.specify/scripts/bash/verify.sh --help
```

**期待される出力:**

```text
Alloy Model Checking Tool (Docker version)

Usage:
  .specify/scripts/bash/verify.sh <alloy-file> [options]

Arguments:
  alloy-file       Path to .als file to verify
                   (e.g., specs/001-purchase/formal/purchase.als)

Options:
  --timeout N      Timeout in seconds (default: 600)
  --format FORMAT  Output format: text, xml (default: text)
  --build          Rebuild Docker image
  --shell          Start Alloy environment shell
  --help           Show this help

Note: Scope is specified in the .als file (e.g., "check PropertyName for 5 but 8 Int")
...
```

### テスト2: Dockerイメージの確認

```bash
docker images | grep alloy
```

**期待される出力:**

```text
model-checking-on-sdd_alloy-verify   latest   abc123def456   5 minutes ago   XYZ MB
```

### テスト3: AIコーディングエージェントでのコマンド確認

```bash
# Claude Code、Cursorなどで
/speckit.modelcheck.formalize
```

**期待される動作:**

- コマンドが認識される
- `spec.md`が見つからない旨のエラーが表示される(正常)

---

## ファイル構成

インストール完了後、プロジェクトは以下の構造になります:

```text
your-project/
│
├── .claude/                                # Claude Code用
│   └── commands/
│       ├── speckit.modelcheck.formalize.md   # ✨ 新規
│       └── speckit.modelcheck.verify.md      # ✨ 新規
│
├── .specify/
│   ├── memory/
│   │   └── constitution.md                # 既存
│   │
│   ├── templates/
│   │   ├── spec-template.md               # 既存
│   │   ├── plan-template.md               # 既存
│   │   ├── modelcheck-model-template.als      # ✨ 新規
│   │   ├── modelcheck-properties-template.md  # ✨ 新規
│   │   └── modelcheck-verification-log-template.md # ✨ 新規
│   │
│   ├── scripts/
│   │   └── bash/
│   │       └── verify.sh                  # ✨ 新規: 検証スクリプト
│   │
│   └── docs/
│       └── GUIDE.md                       # ✨ 新規
│
├── docker/
│   └── alloy/                             # ✨ 新規: Alloy Docker環境
│       ├── Dockerfile
│       ├── verify-alloy.sh
│       └── parse-counterexample.sh        # 反例解析スクリプト
│
├── docker-compose.yaml                     # ✨ 新規
├── .env.example                            # ✨ 新規: カスタマイズ用
│
├── specs/
│   └── {FEATURE_NAME}/
│       ├── spec.md
│       ├── plan.md
│       ├── tasks.md
│       └── formal/                         # /speckit.modelcheck.formalizeで作成
│           ├── {feature}.als
│           ├── properties.md
│           └── verification-log.md
│
└── src/
    └── ... (実装コード)
```

---

## トラブルシューティング

### コマンドが認識されない

```bash
/speckit.modelcheck.formalize
# Error: Command not found
```

**確認:** `ls .claude/commands/speckit.modelcheck.formalize.md`

**解決策:**

- ファイルが正しい場所にコピーされているか確認
- AIコーディングエージェントを再起動

---

### テンプレートが見つからない

```bash
/speckit.modelcheck.formalize
# Error: Template not found: modelcheck-model-template.als
```

**確認:** `ls .specify/templates/modelcheck-*`

**解決策:** テンプレートを再コピー

```bash
cp ${FORMAL_PKG}/templates/modelcheck-* .specify/templates/
```

---

### Dockerイメージのビルドでファイルが見つからない

```bash
docker compose build alloy-verify
# COPY failed: file not found in build context
```

**確認:** `ls docker/alloy/`

**解決策:** docker/alloy/ ディレクトリを再コピー

```bash
mkdir -p docker/alloy
cp -r ${FORMAL_PKG}/docker/* docker/alloy/
```

カスタム配置の場合は環境変数を設定:

```bash
export ALLOY_DOCKER_DIR=<配置先パス>
docker compose build alloy-verify
```

---

### スクリプトの権限エラー

```bash
.specify/scripts/bash/verify.sh
# Permission denied
```

**解決策:**

```bash
chmod +x .specify/scripts/bash/verify.sh
```

---

## 次のステップ

インストールが完了したら:

1. ✅ **ドキュメントを読む**

   ```bash
   cat .specify/docs/GUIDE.md
   ```

2. ✅ **簡単な機能で試す**

   ```bash
   # 仕様作成
   /speckit.specify

   # モデル生成
   /speckit.modelcheck.formalize

   # 検証
   .specify/scripts/bash/verify.sh specs/001-test/formal/test.als

   # 結果文書化
   /speckit.modelcheck.verify
   ```

---

## アンインストール

モデル検査拡張を削除する場合:

```bash
# コマンドを削除（Claude Codeの場合）
rm .claude/commands/speckit.modelcheck.formalize.md
rm .claude/commands/speckit.modelcheck.verify.md

# テンプレートを削除
rm .specify/templates/modelcheck-*

# スクリプトを削除
rm .specify/scripts/bash/verify.sh

# ドキュメントを削除
rm .specify/docs/GUIDE.md

# Docker環境を削除
# Note: インストール時に配置したファイルを削除してください
# rm -rf docker/alloy
# rm docker-compose.yml

# Dockerイメージを削除
docker compose down
docker rmi model-checking-on-sdd_alloy-verify

# 生成されたモデルを削除(オプショナル)
find specs/ -type d -name "formal" -exec rm -rf {} +
```

---

## FAQ

**Q: Javaのインストールは本当に不要ですか?**  
A: はい。Docker内でJavaとAlloyが動作するため、ホストにJavaは不要です。

**Q: Docker Desktopがないと使えませんか?**  
A: macOSの場合はDocker Desktop推奨。Linux/WSLならDocker Engineでも可能。

**Q: M1/M2 Macで動作しますか?**  
A: はい。Alpine LinuxベースのイメージはARM64に対応しています。

**Q: オフライン環境で使えますか?**  
A: Dockerイメージをビルド済みであれば可能。ビルド時のみインターネット接続が必要。

**Q: 既存のSpec Kitファイルに影響はありますか?**  
A: いいえ。すべて新規ファイルの追加のみで、既存ファイルは変更されません。

**Q: CI/CDに統合できますか?**  
A: 可能ですが、今回のスコープ外です。GitHub Actions等でdocker-composeを実行できます。

---

## サポート

**問題が解決しない場合:**

1. **ログを確認**

   ```bash
   # Docker ログ
   docker compose logs alloy-verify
   
   # ビルドログ
   docker compose build --progress=plain alloy-verify
   ```

2. **デバッグモード**

   ```bash
   # Alloyコンテナのシェルに入る
   .specify/scripts/bash/verify.sh --shell

   # コンテナ内で手動実行
   verify-alloy /specs/001-purchase/formal/purchase.als
   ```

---

**インストール完了おめでとうございます!**
詳細な使い方は `GUIDE.md` を参照してください。
