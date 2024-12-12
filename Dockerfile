FROM python:3.12-slim

USER root
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r github && useradd -r -m -g github github

WORKDIR /usr/src/app

USER github:github

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY entrypoint.py .

ENTRYPOINT ["python3", "/usr/src/app/entrypoint.py"]
