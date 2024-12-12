FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

ENV PIP_USER=0
ENV PIP_NO_USER=1
ENV PYTHONUSERBASE=/usr/src/app/.local

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

RUN chown -R appuser:appgroup /usr/src/app

USER appuser

COPY entrypoint.py .

ENTRYPOINT ["python3", "/usr/src/app/entrypoint.py"]
