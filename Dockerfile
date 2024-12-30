FROM alpine:latest
RUN apk add --no-cache \
    bash \
    aws-cli \
    zip \
    && rm -rf /var/cache/apk/*
RUN adduser -D uploader
USER uploader
WORKDIR /uploader
COPY entrypoint.sh /home/uploader/entrypoint.sh
RUN chmod +x /uploader/entrypoint.sh
ENTRYPOINT ["bash", "/uploader/entrypoint.sh"]
