FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    unzip \
    zip \
    awscli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /action

COPY entrypoint.sh /action/entrypoint.sh

RUN chmod +x /action/entrypoint.sh

ENTRYPOINT ["/action/entrypoint.sh"]
