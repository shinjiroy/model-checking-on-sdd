#!/bin/sh
# Alloy CLI検証スクリプト
# コンテナ内で実行される

set -e

ALLOY_JAR="/alloy/alloy.jar"

# ヘルプ表示
show_help() {
    cat << EOF
Alloy Formal Verification Tool

使い方:
  verify-alloy <alloy-file.als> [options]

オプション:
  --scope N        検証スコープを指定 (デフォルト: 5)
  --timeout N      タイムアウト(秒) (デフォルト: 300)
  --format FORMAT  出力フォーマット: text, xml (デフォルト: text)
  --help           このヘルプを表示

例:
  verify-alloy /specs/purchase.als
  verify-alloy /specs/purchase.als --scope 7
  verify-alloy /specs/purchase.als --format xml
EOF
}

# デフォルト値
SCOPE=5
TIMEOUT=300
FORMAT="text"
ALS_FILE=""

# 引数解析
while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --scope)
            SCOPE="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        *)
            if [ -z "$ALS_FILE" ]; then
                ALS_FILE="$1"
            else
                echo "エラー: 複数の.alsファイルが指定されました" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# .alsファイルが指定されているか確認
if [ -z "$ALS_FILE" ]; then
    echo "エラー: .alsファイルが指定されていません" >&2
    echo "" >&2
    show_help
    exit 1
fi

# ファイルの存在確認
if [ ! -f "$ALS_FILE" ]; then
    echo "エラー: ファイルが見つかりません: $ALS_FILE" >&2
    exit 1
fi

echo "================================================"
echo "Alloy 形式検証"
echo "================================================"
echo "ファイル: $ALS_FILE"
echo "スコープ: $SCOPE"
echo "タイムアウト: ${TIMEOUT}秒"
echo "出力形式: $FORMAT"
echo "================================================"
echo ""

# Alloy実行
# Note: Alloy CLIは --check オプションですべてのcheck commandを実行
if [ "$FORMAT" = "xml" ]; then
    java -jar "$ALLOY_JAR" \
        --timeout "$TIMEOUT" \
        --xml \
        "$ALS_FILE"
else
    # テキスト形式(Claude Codeが読みやすい)
    java -jar "$ALLOY_JAR" \
        --timeout "$TIMEOUT" \
        "$ALS_FILE" 2>&1 | \
    awk '
    BEGIN {
        print "検証開始..."
        in_result = 0
        check_count = 0
    }
    
    # Check コマンド検出
    /Executing "Check/ {
        check_count++
        check_name = $0
        gsub(/.*Executing "Check /, "", check_name)
        gsub(/".*/, "", check_name)
        print "\n[Check " check_count ": " check_name "]"
        in_result = 1
        next
    }
    
    # 結果検出
    /No counterexample found/ {
        print "  結果: ✅ PASS (反例なし)"
        print "  詳細: 指定されたスコープ内でプロパティが成立"
        in_result = 0
        next
    }
    
    /Counterexample found/ {
        print "  結果: ❌ FAIL (反例発見)"
        in_result = 1
        next
    }
    
    # 反例の詳細
    in_result && /---/ {
        print "  " $0
        next
    }
    
    in_result && /Skolem/ {
        print "  " $0
        next
    }
    
    # エラー
    /Error:/ {
        print "エラー: " $0
    }
    
    END {
        print "\n================================================"
        print "検証完了: " check_count " 個のプロパティをチェックしました"
        print "================================================"
    }
    '
fi

echo ""
echo "検証が完了しました"
