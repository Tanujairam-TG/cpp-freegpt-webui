FROM ubuntu:23.04

# Use --build-arg LIB_DIR=/usr/lib for arm64 CPUs
ARG LIB_DIR=/local/lib

# Create necessary directories
RUN mkdir -p $LIB_DIR

# Set environment variables
ENV LD_LIBRARY_PATH=$LIB_DIR:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=$LIB_DIR:$LIBRARY_PATH

# Install required dependencies
RUN apt-get update -y && \
    apt-get install -y libcurl4-openssl-dev wget libnss3 nss-plugin-pem ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and extract libcurl-impersonate
ARG LIB_VERSION=v0.6.0-alpha.1
ARG ARCH=$(dpkg --print-architecture)
RUN wget https://github.com/lwthiker/curl-impersonate/releases/download/${LIB_VERSION}/libcurl-impersonate-${LIB_VERSION}.${ARCH}-linux-gnu.tar.gz -O $LIB_DIR/libcurl-impersonate-${LIB_VERSION}.${ARCH}-linux-gnu.tar.gz && \
    tar -xvf $LIB_DIR/libcurl-impersonate-${LIB_VERSION}.${ARCH}-linux-gnu.tar.gz -C $LIB_DIR --strip-components=1 && \
    rm $LIB_DIR/libcurl-impersonate-${LIB_VERSION}.${ARCH}-linux-gnu.tar.gz

# Set working directory
WORKDIR /app

# Copy necessary files
# COPY bin /app/bin
COPY cfg /app/cfg
COPY client /app/client

# Display directory contents for debugging (you can remove these in production) 
RUN ls -l /app/bin
RUN ls -l /app/cfg
RUN ls -l /app/client

# Set working directory for the entry point
WORKDIR /app/bin

# Define entry point command
ENTRYPOINT ["sh", "-c", "./cpp-freegpt-webui ../cfg/cpp-free-gpt.yml"]
