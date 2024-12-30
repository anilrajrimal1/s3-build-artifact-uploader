FROM alpine:latest
RUN apk add --no-cache \
    bash \
    aws-cli \
    zip \
    && rm -rf /var/cache/apk/*
RUN adduser -D uploader
USER uploader
WORKDIR /uploader
COPY . .
ENTRYPOINT ["bash", "entrypoint.sh"]
