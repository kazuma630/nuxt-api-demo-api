# ベースイメージ指定
FROM ruby:2.7.2-alpine

# dockerfile内で使用する変数定義
ARG WORKDIR
ARG RUNTIME_PACKAGES="nodejs tzdata postgresql-dev postgresql git"
ARG DEV_PACKAGES="build-base curl-dev"

# Dockerコンテナ内で使える変数定義
ENV HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# 作業ディレクトリ定義
WORKDIR ${HOME}

# ファイルコピー（ホスト : コンテナ）
COPY Gemfile* ./

RUN apk update && \
    apk upgrade && \
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    bundle install -j4 && \
    apk del build-dependencies

COPY . ./

CMD ["rails", "server", "-b", "0.0.0.0"]