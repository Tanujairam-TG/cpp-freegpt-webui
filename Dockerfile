FROM ubuntu:23.04

ARG LIB_DIR=/local/lib
RUN mkdir -p $LIB_DIR

ENV LD_LIBRARY_PATH=$LIB_DIR:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=$LIB_DIR:$LIBRARY_PATH

RUN apt-get update -y \
    && apt-get install -y libcurl4-openssl-dev wget libnss3 nss-plugin-pem ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/lwthiker/curl-impersonate/releases/download/v0.6.0-alpha.1/libcurl-impersonate-v0.6.0-alpha.1.$(arch)-linux-gnu.tar.gz -P $LIB_DIR \
    && tar -xvf $LIB_DIR/libcurl-impersonate-v0.6.0-alpha.1.$(arch)-linux-gnu.tar.gz -C $LIB_DIR \
    && rm $LIB_DIR/libcurl-impersonate-v0.6.0-alpha.1.$(arch)-linux-gnu.tar.gz

WORKDIR /app

COPY bin /app/bin
COPY cfg /app/cfg
COPY client /app/client

RUN ls /app/bin
RUN ls /app/cfg

WORKDIR /app/bin

ENTRYPOINT ["sh", "-c", "./cpp-freegpt-webui ../cfg/cpp-free-gpt.yml"]
