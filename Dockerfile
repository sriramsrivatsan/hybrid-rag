FROM python:3.11-slim AS builder

ARG CACHEBUST=2025-01-17
WORKDIR /build

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        make \
        build-essential; \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir poetry \
    && poetry --version
