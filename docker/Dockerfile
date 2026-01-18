# Alloy AnalyzerのDockerfile
# Note: Using eclipse-temurin:17-jdk (not alpine) for ARM64 support
# Alpine variant (17-jdk-alpine) does not support ARM64 architecture

FROM eclipse-temurin:17-jdk

# Alloy Analyzerのバージョン
ARG ALLOY_VERSION=6.2.0

# 作業ディレクトリ
WORKDIR /alloy

# Alloy Analyzerをダウンロード & jqをインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget jq && \
    wget -O alloy.jar "https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v${ALLOY_VERSION}/org.alloytools.alloy.dist.jar" && \
    apt-get purge -y wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 検証スクリプトをコピー
COPY verify-alloy.sh /usr/local/bin/verify-alloy
COPY parse-counterexample.sh /usr/local/bin/parse-counterexample
RUN chmod +x /usr/local/bin/verify-alloy /usr/local/bin/parse-counterexample

# デフォルトコマンド
ENTRYPOINT ["verify-alloy"]
CMD ["--help"]
