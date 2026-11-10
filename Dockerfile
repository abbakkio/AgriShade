# =============================================================================
# AgriShadeNet Central Backend Container (FastAPI + SQLite Relational DB)
# =============================================================================

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    DATABASE_URL="sqlite:///./data/agrishadenet.db"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ /app/backend/
COPY edge/ /app/edge/
COPY security/ /app/security/

RUN mkdir -p /app/data

# Seed database on build
RUN python -m backend.seed_data

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Launch uvicorn respecting PORT environment variable for Render / Railway / Fly.io
CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
