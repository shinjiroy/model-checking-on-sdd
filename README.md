# Spec Kit モデル検査拡張

## モチベーション

これはSpec Kitに形式手法の一つであるモデル検査を適用してみようという試みです。

まず一般的に、モデル検査による検証は莫大な工数がかかります。そのため、不具合が出ると人命や多額の経済的な不利益が発生したり、設計工程の後の工程で手戻りが発生すると多額の不利益が発生するような開発で限定的に使われています。
また、モデル検査による検証は比較的高度な専門知識を要します。そのため、それを業務としてこなせる人員は比較的少ないと思われます。

昨今、LLMエージェント(AI)の普及により、様々な専門技術を取り組むハードルが下がりました。モデル検査についても、もっと一般的なWebアプリケーション等の開発フローに組み込めないか検討します。
そして、LLMエージェントを利用した開発手法として仕様駆動開発が主流となりつつあります。この仕様駆動開発で作られる仕様書(仕様定義)の精度、品質を上げるということを目標に置いています。今回は[Spec Kit](https://github.com/github/spec-kit)を想定しています。

---

## 概要

Spec KitワークフローにAlloyを使った形式検証を追加します。ワークフローの中で作られた仕様定義に対して検証したいモデルをAlloyの構文で作成させ、Alloy Analyzerを実行、修正をし、ドキュメントの品質を向上させます。

### 含まれるもの

- **2つの新規コマンド**: `/speckit.formalize`, `/speckit.verify`
- **4つのテンプレート**: モデルテンプレート、プロパティテンプレート、ガイドテンプレート、ログテンプレート
- **Docker環境**: Alloy CLI実行用のDockerfile、docker-compose.yml、検証スクリプト
- **完全なドキュメント**: ガイド、ベストプラクティス、例

### 主要機能

✅ **Docker CLI実行** - GUIなしで自動検証  
✅ **環境統一** - macOS/WSL/Linuxで同一環境  
✅ **Claude Code対応** - 読みやすいテキスト出力  
✅ **1 spec = 1 Alloyモデル** - 明確なトレーサビリティ  
✅ **オプショナルな検証** - 重要な機能のみで使用  
✅ **非侵襲的** - 既存のSpec Kitファイルを変更しない

---

## クイックスタート

### 前提条件

1. **Spec Kitがインストール済み**
2. **Docker環境**
   - macOS: Docker Desktop
   - Linux/WSL: Docker Engine

Note: Javaは不要です。

### インストール

```bash
# プロジェクトルートで実行
cd /path/to/your/speckit-project

# コマンドをコピー
cp -r speckit-formal-extension/commands/* .specify/templates/commands/

# テンプレートをコピー
cp -r speckit-formal-extension/templates/* .specify/templates/

# ドキュメントをコピー
mkdir -p .specify/docs
cp speckit-formal-extension/docs/FORMAL_METHODS_GUIDE_ja.md .specify/docs/

# Docker環境をコピー
cp -r speckit-formal-extension/docker ./
cp speckit-formal-extension/docker-compose.yml ./
cp speckit-formal-extension/verify.sh ./
chmod +x verify.sh

# Dockerイメージをビルド
docker-compose build alloy-verify
```

### 動作確認

```bash
./verify.sh --help
```

---

## 使い方

### 基本ワークフロー

```bash
/speckit.specify                                    # 仕様作成
/speckit.plan                                       # 技術設計
/speckit.formalize                                  # Alloyモデル生成
./verify.sh specs/001-purchase/formal/purchase.als # Docker CLI検証
/speckit.verify                                     # 結果文書化
/speckit.tasks                                      # タスク作成
```

### 検証実行例

```bash
# 基本
./verify.sh specs/001-purchase/formal/purchase.als

# スコープ指定
./verify.sh specs/001-purchase/formal/purchase.als --scope 7

# 再ビルド
./verify.sh specs/001-purchase/formal/purchase.als --build
```

---

## ファイル構成

```bash
speckit-formal-extension/
├── commands/              # Spec Kitコマンド
│   ├── formalize.md
│   └── verify.md         # Docker対応
├── templates/             # テンプレート
│   ├── formal-model-template.als
│   ├── formal-properties-template.md
│   ├── formal-guide-template.md
│   └── formal-verification-log-template.md
├── docs/                  # ドキュメント
│   ├── README_ja.md      # このファイル
│   ├── FORMAL_METHODS_GUIDE_ja.md
│   └── INSTALL_ja.md
├── docker/                # Docker環境
│   ├── Dockerfile
│   └── verify-alloy.sh
├── docker-compose.yml
└── verify.sh              # 検証スクリプト
```

---

## 詳細ドキュメント

- **FORMAL_METHODS_GUIDE_ja.md** - 完全な統合ガイド
- **INSTALL_ja.md** - インストール手順の詳細
