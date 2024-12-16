FROM alpine:latest

RUN apk update && apk add --no-cache \
    aws-cli \
    zip \
    bash \
    && adduser -D -u 1000 appuser  # Create a non-root user

WORKDIR /code

COPY entrypoint.sh /code/entrypoint.sh

RUN chmod +x /code/entrypoint.sh

USER appuser

ENTRYPOINT ["/code/entrypoint.sh"]
