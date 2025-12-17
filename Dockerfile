FROM python:3.11-slim

RUN echo "✅ ACTIVE DOCKERFILE CONFIRMED"

RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg \
 && rm -rf /var/lib/apt/lists/*
