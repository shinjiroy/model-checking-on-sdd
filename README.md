# Spec Kit モデル検査拡張

## モチベーション

これはSpec Kitに形式手法の一つであるモデル検査を適用してみようという試みです。

まず一般的に、モデル検査による検証は莫大な工数がかかります。そのため、不具合が出ると人命や多額の経済的な不利益が発生したり、設計工程の後の工程で手戻りが発生すると多額の不利益が発生するような開発で限定的に使われています。  
また、モデル検査による検証は比較的高度な専門知識を要します。そのため、それを業務としてこなせる人員は比較的少ないと思われます。

昨今、LLMエージェント(AI)の普及により、様々な技術についての工数や学習コストが下がりました。モデル検査についてももっと一般的なWebアプリケーション等の開発フローに組み込めないか検討します。

LLMエージェントを利用した開発手法として仕様駆動開発が主流となりつつあります。ここでは[Spec Kit](https://github.com/github/spec-kit)を使うことにします。  
Spec Kitではドキュメントを検証する機構がありますが、曖昧でないことや複数のドキュメント間の整合性のチェック等を自然言語的に検証するのみであり、書いてある事の正しさを形式的に科学的に検証したいと考えます。  
ここではモデル検査を活用し、仕様駆動開発で作られる仕様書(仕様定義, spec.md)の精度、品質を上げるということを目標に置いています。

---

## 概要

Spec KitワークフローにAlloyを使った形式検証を追加します。ワークフローの中で作られた仕様定義に対して検証したいモデルをAlloyの構文で作成させ、Alloy Analyzerを実行、修正をし、ドキュメントの品質を向上させます。

### 含まれるもの

- **2つの新規コマンド**: `/speckit.modelcheck.formalize`, `/speckit.modelcheck.verify`
- **3つのテンプレート**: モデルテンプレート、プロパティテンプレート、ログテンプレート
- **Docker環境**: Alloy CLI実行用のDockerfile、docker-compose.yml、検証スクリプト
- **完全なドキュメント**: ガイド、ベストプラクティス、例

### 主要機能

- ✅ **Docker CLI実行** - GUIなしで自動検証
- ✅ **環境統一** - macOS/WSL/Linuxで同一環境
- ✅ **Claude Code対応** - 読みやすいテキスト出力
- ✅ **反例の構造化表示** - LLMエージェントが解釈しやすい形式で出力
- ✅ **1 spec = 1 Alloyモデル** - 明確なトレーサビリティ
- ✅ **オプショナルな検証** - 重要な機能のみで使用
- ✅ **非侵襲的** - 既存のSpec Kitファイルを変更しない

---

## クイックスタート

### 前提条件

1. **Spec Kitがリポジトリに導入済み**
2. **Docker環境**
   - macOS: Docker Desktop
   - Linux/WSL: Docker Engine

### インストール

```bash
# プロジェクトルートで実行
cd /path/to/your-project

# コマンドをコピー
cp -r /path/to/model-checking-on-sdd/commands/* .specify/templates/commands/

# テンプレートをコピー
cp -r /path/to/model-checking-on-sdd/templates/* .specify/templates/

# Docker環境をコピー
cp -r /path/to/model-checking-on-sdd/docker ./
cp /path/to/model-checking-on-sdd/docker-compose.yaml ./
mkdir -p .specify/scripts/bash
cp /path/to/model-checking-on-sdd/scripts/verify.sh .specify/scripts/bash/
chmod +x .specify/scripts/bash/verify.sh

# Dockerイメージをビルド
mkdir -p docker/alloy
cp -r ${FORMAL_PKG}/docker/* docker/alloy/
```

### 動作確認

```bash
.specify/scripts/bash/verify.sh --help
```

---

## 使い方

### 基本ワークフロー

```bash
/speckit.specify                                    # 仕様作成
/speckit.plan                                       # 技術設計
/speckit.modelcheck.formalize                       # Alloyモデル生成
/speckit.modelcheck.verify                          # 検証実行＆結果文書化（自動）
/speckit.tasks                                      # タスク作成
```

### 検証実行例（手動実行する場合）

> **Note**: `/speckit.modelcheck.verify`コマンドが自動で検証を実行するため、
> 通常は手動実行は不要です。以下は直接実行する場合の例です。

```bash
# 基本
.specify/scripts/bash/verify.sh specs/001-purchase/formal/purchase.als

# タイムアウト指定
.specify/scripts/bash/verify.sh specs/001-purchase/formal/purchase.als --timeout 300

# 再ビルド
.specify/scripts/bash/verify.sh specs/001-purchase/formal/purchase.als --build
```

> **Note**: スコープはalsファイル内で指定します（例: `check PropertyName for 7 but 8 Int`）

---

## ファイル構成

```bash
model-checking-on-sdd/
├── commands/              # Spec Kitコマンド
│   ├── speckit.modelcheck.formalize.md
│   └── speckit.modelcheck.verify.md
├── templates/             # テンプレート
│   ├── modelcheck-model-template.als
│   ├── modelcheck-properties-template.md
│   └── modelcheck-verification-log-template.md
├── GUIDE.md               # モデル検査ガイド
├── INSTALL.md             # インストール手順
├── docker/                # Docker環境
│   ├── Dockerfile
│   ├── verify-alloy.sh
│   └── parse-counterexample.sh  # 反例解析
├── docker-compose.yaml
└── scripts/
    └── verify.sh          # 検証スクリプト
```

---

## 詳細ドキュメント

- **GUIDE.md** - 完全なモデル検査ガイド
- **INSTALL.md** - インストール手順の詳細
