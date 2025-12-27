# Alloy AnalyzerのDockerfile

FROM eclipse-temurin:17-jdk-alpine

# Alloy Analyzerのバージョン
ARG ALLOY_VERSION=6.1.0

# 作業ディレクトリ
WORKDIR /alloy

# Alloy Analyzerをダウンロード
RUN apk add --no-cache wget && \
    wget -O alloy.jar "https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v${ALLOY_VERSION}/org.alloytools.alloy.dist.jar" && \
    apk del wget

# 検証スクリプトをコピー
COPY verify-alloy.sh /usr/local/bin/verify-alloy
RUN chmod +x /usr/local/bin/verify-alloy

# デフォルトコマンド
ENTRYPOINT ["verify-alloy"]
CMD ["--help"]
