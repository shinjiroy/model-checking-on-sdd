# Alloy AnalyzerのDockerfile

FROM eclipse-temurin:17-jdk-alpine

# Alloy Analyzerのバージョン
ARG ALLOY_VERSION=6.2.0

# 作業ディレクトリ
WORKDIR /alloy

# Alloy Analyzerをダウンロード & jqをインストール
RUN apk add --no-cache wget jq && \
    wget -O alloy.jar "https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v${ALLOY_VERSION}/org.alloytools.alloy.dist.jar" && \
    apk del wget

# 検証スクリプトをコピー
COPY verify-alloy.sh /usr/local/bin/verify-alloy
COPY parse-counterexample.sh /usr/local/bin/parse-counterexample
RUN chmod +x /usr/local/bin/verify-alloy /usr/local/bin/parse-counterexample

# デフォルトコマンド
ENTRYPOINT ["verify-alloy"]
CMD ["--help"]
