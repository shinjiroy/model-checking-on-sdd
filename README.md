# Spec Kit 形式検証拡張

これはSpecKitに形式手法(モデル検査)を適用してみようという試みです。

## 概要

この拡張はSpec KitワークフローにAlloyを使った形式検証を追加します。チームが実装前に仕様の性質を数学的に検証し、設計上の欠陥を早期に発見できるようにします。

### 含まれるもの

- **2つの新規コマンド**: `/speckit.formalize`, `/speckit.verify`
- **4つのテンプレート**: モデルテンプレート、プロパティテンプレート、ガイドテンプレート、ログテンプレート
- **完全なドキュメント**: チーム向けガイド、ベストプラクティス、例
- **非侵襲的**: 既存のSpec Kitファイルを変更しない

### 主要機能

✅ **1 spec = 1 Alloyモデル** - 明確なトレーサビリティ  
✅ **オプショナルな検証** - 重要な機能のみで使用  
✅ **自己完結型** - すべての形式検証作業は`formal/`サブディレクトリ内  
✅ **チームフレンドリー** - 専門家と初心者の両方向けガイド  
✅ **反復的ワークフロー** - 実務での使用を想定した設計

---

## クイックスタート

### 前提条件

1. **Spec Kitがインストール済み** - これは拡張であり、置き換えではありません
2. **Alloy Analyzer** - <https://alloytools.org/download.html> からダウンロード
3. **Java 8以上** - Alloy Analyzerに必要

### インストール

#### オプション1: 手動インストール

1. Spec Kitインストール先にファイルをコピー:

   ```bash
   cp -r templates/commands/* .specify/templates/commands/
   cp -r templates/*.{als,md} .specify/templates/
   cp FORMAL_METHODS_GUIDE.md .specify/docs/
   ```

2. AIエージェントの設定を更新(必要に応じて):
   - `/speckit.formalize` コマンド参照を追加
   - `/speckit.verify` コマンド参照を追加

#### オプション2: Spec Kit CLIを使用

```bash
# Spec Kitが拡張機能をサポートする場合(将来的な機能)
speckit install formal-verification
```

### 確認

インストールの確認:

```bash
ls .specify/templates/commands/
# 表示されるべきもの: formalize.md, verify.md, ...

ls .specify/templates/
# 表示されるべきもの: formal-model-template.als, formal-properties-template.md, ...
```

---

## ファイル構成

インストール後、Spec Kitプロジェクトは以下のようになります:

```sh
.specify/
├── templates/
│   ├── commands/
│   │   ├── formalize.md                      # 新規: Alloyモデル生成
│   │   └── verify.md                         # 新規: 検証結果記録
│   ├── formal-model-template.als             # 新規: Alloyモデルテンプレート
│   ├── formal-properties-template.md         # 新規: プロパティチェックリスト
│   ├── formal-guide-template.md              # 新規: チーム検証ガイド
│   └── formal-verification-log-template.md   # 新規: 検証ログ
└── docs/
    └── FORMAL_METHODS_GUIDE.md               # 新規: 完全ガイド

specs/{FEATURE_NAME}/
├── spec.md                                    # 既存
├── plan.md                                    # 既存
├── tasks.md                                   # 既存
└── formal/                                    # 新規: formalizeで作成
    ├── {feature}.als                          # Alloyモデル
    ├── properties.md                          # 検証チェックリスト
    ├── guide.md                               # チーム向け手順
    └── verification-log.md                    # 検証履歴
```

---

## 使い方

### 基本ワークフロー

```bash
# 標準Spec Kitワークフロー
/speckit.constitution
/speckit.specify       # spec.md作成
/speckit.plan          # plan.md作成

# 新規: 形式検証(オプショナル)
/speckit.formalize     # Alloyモデル生成
# [Alloy Analyzerで手動検証]
/speckit.verify        # 結果を記録

# 標準ワークフローを続行
/speckit.tasks         # tasks.md作成
# [実装]
```

### 使用例

```sh
$ /speckit.specify
> [AIが購入フローのspec.mdを作成]

$ /speckit.plan
> [AIがplan.mdを作成]

# 判断: これは安全性が重要(決済)なので、形式的に検証しよう
$ /speckit.formalize
> 形式仕様を生成中...
> 作成: specs/001-purchase/formal/purchase.als
> 作成: specs/001-purchase/formal/properties.md
> 作成: specs/001-purchase/formal/guide.md

# Alloy Analyzerを手動で開く
$ alloy
> [GUIが開く、purchase.alsを読み込み、チェックを実行]
> NoDoublePurchase: ✅ PASS
> InventoryConsistency: ❌ FAIL (反例が表示される)

# 結果を記録
$ /speckit.verify
> 検証結果を報告してください...
> [ユーザーが結果を提供]
> 更新: properties.md, verification-log.md
> InventoryConsistencyの修正案: [...]

# モデルを修正、再検証
$ [提案に基づいてpurchase.alsを編集]
$ [Alloy Analyzerで再実行]
$ /speckit.verify
> すべてのプロパティが合格 ✅

# 実装へ進む
$ /speckit.tasks
> [AIがtasks.mdを作成、設計への確信を持って]
```

---

## コマンド

### `/speckit.formalize`

**目的**: `spec.md`からAlloy形式仕様を生成

**使用タイミング**: spec.mdとplan.mdが完成後、安全性が重要な機能に対して

**作成されるもの**:

- `formal/{feature}.als` - Alloyモデル(単一ファイル)
- `formal/properties.md` - 検証チェックリスト
- `formal/guide.md` - チーム向け手順

**例**:

```sh
/speckit.formalize

> spec.mdを分析中...
> 特定されたエンティティ: User, Product, Order
> 特定された操作: purchase, addToCart
> Alloyモデルを生成中...
> 
> 形式仕様を作成:
> - formal/purchase.als (142行)
> - formal/properties.md (3つのプロパティ)
> - formal/guide.md
> 
> 次: Alloy Analyzerで検証、その後/speckit.verifyを実行
```

---

### `/speckit.verify`

**目的**: 形式検証結果を記録

**使用タイミング**: Alloy Analyzer GUIで検証を実行した後

**実行内容**:

- 結果報告を案内
- `properties.md`を合格/不合格ステータスで更新
- `verification-log.md`に追記
- 失敗時の修正案を提案

**例**:

```sh
/speckit.verify

> Alloy Analyzerで検証を実行し、結果を報告してください。
> 
> 形式: PropertyName: PASS/FAIL [メモ]
> 

ユーザー: NoDoublePurchase: PASS
ユーザー: InventoryConsistency: FAIL - 同時購入で在庫がマイナスになった
ユーザー: BalanceIntegrity: PASS

> ありがとうございます。ドキュメントを更新中...
> 
> 結果: 2/3 プロパティが合格
> ✅ NoDoublePurchase
> ❌ InventoryConsistency  
> ✅ BalanceIntegrity
> 
> InventoryConsistency失敗の分析:
> [修正案を提案...]
```

---

## 重要な概念

### 1 spec = 1 Alloyモデル

各`specs/{FEATURE}/`ディレクトリは`formal/`内に**ちょうど1つ**の`.als`ファイルを持つべきです。

✅ **良い例**:

```sh
specs/001-purchase/
  └── formal/
      └── purchase.als
```

❌ **悪い例**(specを分割すべき):

```sh
specs/001-everything/
  └── formal/
      ├── purchase.als
      ├── inventory.als
      └── payment.als
```

### 形式検証はオプショナル

すべての機能が形式検証を必要とするわけではありません。以下に使用

- ✅ 決済処理
- ✅ 在庫管理  
- ✅ 認証フロー
- ✅ 複雑な状態機械
- ❌ 単純なCRUD
- ❌ UIロジック
- ❌ 外部API呼び出し

### 非侵襲的な統合

形式検証は以下を変更しません

- ❌ `spec.md`
- ❌ `plan.md`
- ❌ `tasks.md`
- ❌ 既存のSpec Kitファイル

すべての形式検証作業は独立した`formal/`ディレクトリ内に留まります。

---

## 形式検証を使うタイミング

### 判断フレームワーク

以下の質問に答えてください:

1. **安全性が重要?** (間違いで金銭的損失/データ破損/セキュリティ侵害が起こる)
2. **複雑な状態遷移?** (複数の状態、複雑なルール)
3. **並行性の問題?** (共有リソース、競合状態)
4. **非自明なビジネスロジック?** (複雑なルール、エッジケース)

**2つ以上が「はい」** → 形式検証を使用  
**すべて「いいえ」** → 形式検証をスキップ

### 推奨対象

| 機能タイプ             | 検証?    | 理由              |
| ---------------------- | -------- | ----------------- |
| 決済処理               | ✅ はい  | 金銭的安全性      |
| ユーザーログインフロー | ✅ はい  | セキュリティ重要  |
| ショッピングカート     | ✅ はい  | 複雑な状態 + 在庫 |
| 表示フォーマット       | ❌ いいえ| UIロジック        |
| APIページネーション    | ❌ いいえ| 単純なロジック    |
| メールテンプレート     | ❌ いいえ| 非クリティカル    |

---

## チームワークフロー

### 役割

**仕様作成者**

- `spec.md`を書く
- 形式検証が必要か判断
- 生成されたAlloyモデルをレビュー

**リーダー（形式手法分かる人）**

- `/speckit.formalize`を実行
- 反例を解釈
- チームにAlloyの基礎を教える

**チームメンバー**

- `guide.md`を使って検証を実行
- 結果を報告
- 質問を提起

### 検証プロセス

1. **作成者**がspec.mdを作成、検証が必要と判断
2. **リーダー**が`/speckit.formalize`を実行、モデルをレビュー
3. **リーダー**がAlloy Analyzerで初回検証を実施
4. **リーダー**が`/speckit.verify`を実行して記録
5. 失敗があれば:
   - **リーダー**が反例を分析
   - **チーム**が修正を議論(モデル vs. 仕様)
   - 修正して再検証(反復)
6. すべて合格したら:
   - **リーダー**がドキュメントを更新
   - **チーム**が実装へ進む

---

## 役割別ドキュメント

### チームメンバー向け

最初に読むもの:

- **`FORMAL_METHODS_GUIDE.md`** - 完全ガイド(これがメインリソース)
- **`specs/{FEATURE}/formal/guide.md`** - 機能固有の手順

### リーダー（形式手法分かる人）向け

参照資料:

- **`templates/commands/formalize.md`** - formalizeコマンドの動作
- **`templates/commands/verify.md`** - verifyコマンドの動作
- **`templates/formal-model-template.als`** - Alloyモデルの構造

### 生成されるドキュメント

形式検証を持つ各機能には:

- **`formal/properties.md`** - 検証されるプロパティ
- **`formal/verification-log.md`** - 検証の履歴記録
- **`formal/guide.md`** - チーム固有の検証手順

---

## トラブルシューティング

### Alloy Analyzerが起動しない

- Java 8以上がインストールされているか確認: `java -version`
- <https://alloytools.org/download.html> から再ダウンロード

### モデルの検証が遅すぎる

- スコープを減らす: `for 3`を`for 5`の代わりに試す
- モデルを簡略化: 一時的にいくつかのファクトをコメントアウト

### 反例が理解できない

- インスタンスグラフをゆっくり読む
- リーダー（形式手法分かる人）に助けを求める
- チームチャンネルにスクリーンショットを共有

### プロパティが間違っているように見えるが合格する

- スコープを増やす(`for 7`が必要かも)
- モデルが過度に制約されているか確認
- アサーションのロジックをレビュー

詳細なトラブルシューティングは`FORMAL_METHODS_GUIDE.md`を参照

---

## 例

### 例1: 購入フロー

機能: ユーザーが商品を購入、残高と在庫が減少

**コマンド**:

```bash
/speckit.formalize
```

**生成**(`formal/purchase.als`):

```alloy
sig User { balance: one Int }
sig Product { price: one Int, stock: one Int }

fact ValidValues {
    all u: User | u.balance >= 0
    all p: Product | p.price >= 0 and p.stock >= 0
}

pred canPurchase[u: User, p: Product] {
    u.balance >= p.price
    p.stock > 0
}

assert NoNegativeBalance { ... }
assert NoNegativeStock { ... }

check NoNegativeBalance for 5
check NoNegativeStock for 5
```

**検証**: 両方とも合格 ✅  
**結果**: 実装へ進む

---

### 例2: 並行在庫

機能: 2人のユーザーが最後の商品を購入しても在庫がマイナスにならない

**初期モデル**: ❌ 失敗(反例で在庫 = -1)  
**修正**: アトミック購入制約を追加  
**再検証**: ✅ 合格  
**結果**: コーディング前に並行性問題を発見!

完全な例は`FORMAL_METHODS_GUIDE.md`を参照

---

## Spec Kitとの統合

### 変更されないSpec Kitファイル

これらのファイルは以前と同じように動作:

- `spec.md` - 自然言語仕様(変更なし)
- `plan.md` - 技術設計(変更なし)
- `tasks.md` - 実装タスク(変更なし)
- `constitution.md` - プロジェクト原則(オプションで形式検証ポリシーを追加可能)

### 新しいオプショナルディレクトリ

```sh
specs/{FEATURE_NAME}/formal/
```

`/speckit.formalize`を実行したときのみ作成されます。形式検証を必要としない機能では無視できます。

### ワークフローの互換性

```text
標準Spec Kit:
constitution → specify → plan → tasks → implement

形式検証あり:
constitution → specify → plan → [formalize → verify] → tasks → implement
                                  ^^^^^^^^^^^^^^^^^^^^^^
                                  オプショナル、重要機能のみ
```

---

## 設定(オプショナル)

### Constitutionへの追加

形式検証を標準プラクティスとして確立したい場合:

**`.specify/memory/constitution.md`**:

```markdown
# 第X条: 形式検証

以下に対してAlloyによる形式検証を**推奨**:
- 決済および金融操作
- 在庫管理
- 認証フロー
- 複雑な状態機械

プロセス:
1. `/speckit.plan`の後、形式検証が必要か判断
2. `/speckit.formalize`を実行してAlloyモデルを生成
3. Alloy Analyzerで検証
4. `/speckit.verify`を実行して結果を記録
5. すべてのプロパティが合格するまで反復
6. その後で`/speckit.tasks`へ進む

注意: 形式検証はオプショナルであり、標準的な仕様レビューを置き換えるものではありません。
```

### チームカスタマイズ

チームに合わせてテンプレートを編集:

- **`templates/formal-guide-template.md`** - チーム固有のチャンネル、連絡先を追加
- **`templates/formal-model-template.als`** - 会社固有の規約を追加
- **`FORMAL_METHODS_GUIDE.md`** - 社内の例、ポリシーを追加

---

## FAQ

**Q: Alloyを学ぶ必要がありますか?**  
A: チームメンバーは深いAlloy知識なしでGUIを使って検証できます。リーダー（形式手法分かる人）はAlloyの基礎を学ぶべきです。

**Q: すべての機能で必須ですか?**  
A: いいえ!安全性が重要な機能のみで使用してください。ほとんどの機能はスキップできます。

**Q: 形式検証で問題が見つかったら?**  
A: それが目標です!コーディング前に設計を修正します。本番バグより安価です。

**Q: TLA+など他のツールは使えますか?**  
A: この拡張はシンプルさのためAlloy専用です。1つのツールを習得する方が、複数のツールを浅く知るよりも優れています。

**Q: 形式手法の専門家がいない場合は?**  
A: Alloyチュートリアル(<http://alloytools.org/tutorials/online/)から始めてください。シンプルなモデルから開始。実践で学びましょう。>

**Q: 開発が遅くなりませんか?**  
A: 重要な機能では、後期段階の設計変更を防ぐことで全体的な納期を早めます。

**Q: 検証にどれくらいかかりますか?**  
A: モデル生成: 2-5分。検証実行: 数秒〜数分。失敗の反復: 状況次第。初回の合計: 30-60分。経験とともに高速化。

**Q: プロパティが合格しない場合は?**  
A: 設計に実際の問題がある(見つけて良かった!)、またはプロパティが厳しすぎる(洗練する)。時にはプロパティが証明不可能と分かること自体がシステムについての学びになります。

---

## サポート

### ドキュメント

- **`FORMAL_METHODS_GUIDE.md`** - 例を含む完全ガイド
- **`specs/{FEATURE}/formal/guide.md`** - 機能固有の手順
- Alloyチュートリアル: <http://alloytools.org/tutorials/online/>

### コミュニティ

- Spec Kit: <https://github.com/github/spec-kit>
- Alloy: <https://alloytools.discourse.group>

### 社内

- リーダー（形式手法分かる人）: {LEAD_NAME}
- チームチャンネル: {TEAM_CHANNEL}

---

## コントリビューション

バグを見つけた?提案がある?

- チームリポジトリにissueを開く
- 学習内容をドキュメントに反映
- 成功した検証の例を共有

---

## ライセンス

この拡張はSpec Kitインストールのライセンス(通常MIT)に従います。

---

## 変更履歴

### バージョン1.0 (2025-01-XX)

- 初回リリース
- 2つのコマンド: formalize, verify
- 4つのテンプレート
- 完全なドキュメント
- 例とトラブルシューティング

---

## クレジット

**作成**: DLsite プラットフォーム開発チーム  
**保守**: 山口(リーダー（形式手法分かる人）)  
**ベース**: GitHub Spec Kit (github/spec-kit)  
**形式手法**: Alloy (alloytools.org)

---

**始める準備ができましたか?**  
完全な手順と例については`FORMAL_METHODS_GUIDE.md`を読んでください。
