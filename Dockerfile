# Use a more specific base image with LTS support
FROM ubuntu:20.04

# Set a non-root user for better security
ARG USER=myuser
ARG UID=1000
ARG GID=1000

# Create a non-root user
RUN groupadd -g $GID -r $USER && useradd -u $UID --create-home -r -g $USER $USER

# Set the working directory
WORKDIR /app

# Create directories and set permissions
RUN mkdir -p /local/lib && chown -R $USER:$USER /local

# Switch to non-root user
USER $USER

# Set environment variables
ENV LD_LIBRARY_PATH=/local/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=/local/lib:$LIBRARY_PATH

# Update package list and install necessary packages
RUN sudo apt-get update -y && sudo apt-get install -y libcurl4-openssl-dev wget libnss3 nss-plugin-pem ca-certificates

# Download and extract libcurl-impersonate
ARG ARCH=amd64
RUN wget https://github.com/lwthiker/curl-impersonate/releases/download/v0.6.0-alpha.1/libcurl-impersonate-v0.6.0-alpha.1.$ARCH-linux-gnu.tar.gz -P /local/lib \
    && tar -xvf /local/lib/libcurl-impersonate-v0.6.0-alpha.1.$ARCH-linux-gnu.tar.gz -C /local/lib \
    && rm /local/lib/libcurl-impersonate-v0.6.0-alpha.1.$ARCH-linux-gnu.tar.gz

# Copy application files
COPY --chown=$USER:$USER bin /app/bin
COPY --chown=$USER:$USER cfg /app/cfg
COPY --chown=$USER:$USER client /app/client

# Display directory contents for debugging
RUN ls /app/bin && ls /app/cfg

# Set the working directory to /app/bin
WORKDIR /app/bin

# Define the entry point
ENTRYPOINT ["sh", "-c", "./cpp-freegpt-webui ../cfg/cpp-free-gpt.yml"]
