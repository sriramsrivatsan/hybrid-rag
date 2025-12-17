###################################### Stage 1: BUILD ######################################

FROM python:3.11-slim AS builder

WORKDIR /build

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        make \
        build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry \
    && poetry --version

# Copy project files
COPY hybrid_rag hybrid_rag
COPY tests tests
COPY .pre-commit-config.yaml .pre-commit-config.yaml
COPY Makefile Makefile
COPY pyproject.toml pyproject.toml
COPY poetry.lock* ./

# Build wheel
RUN make build

###################################### Stage 2: RUNTIME ######################################

FROM python:3.11-slim

WORKDIR /Hybrid-Search-RAG

# Install runtime system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        supervisor \
        ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy wheel from builder
COPY --from=builder /build/dist/*.whl .

# Install wheel
RUN pip install --no-cache-dir *.whl && rm -f *.whl

##################
# App files
##################
COPY chat_restapi chat_restapi
COPY chat_streamlit_app chat_streamlit_app
COPY .env.example chat_restapi/.env.example
COPY .env.example chat_streamlit_app/.env.example

# Supervisor config
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 8000 8501

# Start Supervisor
CMD ["supervisord", "-n"]
