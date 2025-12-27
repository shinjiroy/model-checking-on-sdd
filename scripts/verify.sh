#!/bin/bash
# Alloy検証実行スクリプト(ホスト側)
# Docker経由でAlloy検証を実行
# 配置場所: .specify/scripts/bash/verify.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# プロジェクトルートを探索（docker-compose.yamlがある場所）
find_project_root() {
    local dir="$SCRIPT_DIR"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/docker-compose.yaml" ]] || [[ -f "$dir/docker-compose.yml" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo ""
    return 1
}

PROJECT_ROOT="$(find_project_root)"
if [[ -z "$PROJECT_ROOT" ]]; then
    echo -e "${RED}エラー: docker-compose.yaml が見つかりません${NC}" >&2
    echo "プロジェクトルートに docker-compose.yaml を配置してください" >&2
    exit 1
fi

cd "$PROJECT_ROOT"

# .env ファイルがあれば読み込む（ALLOY_DOCKER_DIR等の設定用）
if [[ -f ".env" ]]; then
    set -a
    source .env
    set +a
fi

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    cat << EOF
${GREEN}Alloy 形式検証ツール (Docker版)${NC}

使い方:
  ./verify.sh <alloy-file> [options]

引数:
  alloy-file       検証する.alsファイルのパス
                   (例: specs/001-purchase/formal/purchase.als)

オプション:
  --scope N        検証スコープ (デフォルト: 5)
  --timeout N      タイムアウト秒数 (デフォルト: 300)
  --format FORMAT  出力形式: text, xml (デフォルト: text)
  --build          Dockerイメージを再ビルド
  --shell          Alloy環境のシェルを起動
  --help           このヘルプを表示

例:
  # 基本的な検証
  ./verify.sh specs/001-purchase/formal/purchase.als

  # スコープを指定
  ./verify.sh specs/001-purchase/formal/purchase.als --scope 7

  # イメージを再ビルドして検証
  ./verify.sh specs/001-purchase/formal/purchase.als --build

  # デバッグ用シェル起動
  ./verify.sh --shell
EOF
}

# Dockerイメージのビルド
build_image() {
    echo -e "${YELLOW}Dockerイメージをビルド中...${NC}"
    docker-compose build alloy-verify
    echo -e "${GREEN}ビルド完了${NC}"
}

# シェル起動
start_shell() {
    echo -e "${YELLOW}Alloy環境のシェルを起動します...${NC}"
    echo "終了するには 'exit' を入力してください"
    docker-compose run --rm alloy-shell
}

# デフォルト値
BUILD=false
SHELL_MODE=false
ALS_FILE=""
VERIFY_ARGS=""

# 引数解析
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --build)
            BUILD=true
            shift
            ;;
        --shell)
            SHELL_MODE=true
            shift
            ;;
        --scope|--timeout|--format)
            VERIFY_ARGS="$VERIFY_ARGS $1 $2"
            shift 2
            ;;
        *)
            if [[ -z "$ALS_FILE" ]]; then
                ALS_FILE="$1"
            else
                echo -e "${RED}エラー: 複数の.alsファイルが指定されました${NC}" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# シェルモード
if [[ "$SHELL_MODE" == true ]]; then
    start_shell
    exit 0
fi

# .alsファイルが指定されているか確認
if [[ -z "$ALS_FILE" ]]; then
    echo -e "${RED}エラー: .alsファイルが指定されていません${NC}" >&2
    echo ""
    show_help
    exit 1
fi

# ファイルの存在確認
if [[ ! -f "$ALS_FILE" ]]; then
    echo -e "${RED}エラー: ファイルが見つかりません: $ALS_FILE${NC}" >&2
    exit 1
fi

# 必要に応じてビルド
if [[ "$BUILD" == true ]]; then
    build_image
fi

# Dockerイメージが存在するか確認
if ! docker-compose images alloy-verify | grep -q alloy-verify; then
    echo -e "${YELLOW}Dockerイメージが見つかりません。ビルドします...${NC}"
    build_image
fi

# 検証実行
echo -e "${GREEN}Alloy検証を開始します...${NC}"
echo ""

# Docker経由で検証実行
# specs/以下の相対パスに変換
REL_PATH="${ALS_FILE#specs/}"
docker-compose run --rm alloy-verify "/specs/$REL_PATH" $VERIFY_ARGS

EXIT_CODE=$?

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✓ 検証が正常に完了しました${NC}"
else
    echo -e "${RED}✗ 検証中にエラーが発生しました (終了コード: $EXIT_CODE)${NC}"
fi

exit $EXIT_CODE
