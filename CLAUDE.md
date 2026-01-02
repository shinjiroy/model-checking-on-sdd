# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Spec Kit（仕様駆動開発フレームワーク）に Alloy を使ったモデル検査を統合する拡張プロジェクト。LLMエージェントを用いた開発において、API仕様の正確性を検証可能にする。

## コマンド

### Alloy検証実行

```bash
# Dockerイメージのビルド（初回のみ）
docker-compose build alloy-verify

# 検証実行
.specify/scripts/bash/verify.sh specs/{FEATURE_NAME}/formal/{feature}.als

# オプション付き実行
.specify/scripts/bash/verify.sh --scope 5 --timeout 120 specs/{FEATURE}/formal/{feature}.als
```

### Spec Kitコマンド（ワークフロー順）

```text
/speckit.specify              # 仕様作成
/speckit.plan                 # 技術設計
/speckit.modelcheck.formalize # Alloyモデル生成
/speckit.modelcheck.verify    # 検証結果の文書化
/speckit.tasks                # タスク生成
/speckit.implement            # 実装
```

## アーキテクチャ

### ディレクトリ構造（インストール後）

```text
.claude/commands/                    # Claude Code用カスタムコマンド
.specify/
├── templates/                       # Alloyモデル・検証テンプレート
└── scripts/bash/                    # 検証スクリプト（verify.sh）
docker/alloy/                        # Alloy CLI実行環境（カスタマイズ可能）
```

### 配布パッケージ構造（このリポジトリ）

```text
commands/                   # → .claude/commands/ へコピー
templates/                  # → .specify/templates/ へコピー
scripts/                    # → .specify/scripts/bash/ へコピー
docker/                     # → docker/alloy/ へコピー
```

### モデル検査成果物の配置

```text
specs/{FEATURE_NAME}/
├── spec.md                 # 仕様（変更しない）
├── plan.md                 # 技術設計（変更しない）
└── formal/                 # モデル検査成果物（ここに配置）
    ├── {feature}.als       # Alloyモデル
    ├── properties.md       # 検証プロパティ
    └── verification-log.md # 検証ログ
```

## 設計原則

1. **1仕様 = 1 Alloyモデル**: 明確なトレーサビリティを維持。モデル > 200行なら仕様分割を検討
2. **非侵襲性**: `spec.md`, `plan.md`, `tasks.md` を変更しない。モデル検査成果物は `formal/` に配置
3. **環境統一**: Docker経由でAlloy CLI検証。ローカルJava環境不要

## Alloyモデル作成時の注意

- Facts（不変式）は 1 concept = 1 fact で分離
- スコープは小さい値（3）から段階的に増加
- `.specify/templates/modelcheck-model-template.als` を参考に構造化
