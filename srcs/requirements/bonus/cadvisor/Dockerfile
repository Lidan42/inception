FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/google/cadvisor/releases/download/v0.47.0/cadvisor-v0.47.0-linux-amd64 \
    -O /usr/local/bin/cadvisor \
    && chmod +x /usr/local/bin/cadvisor

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/cadvisor"]
