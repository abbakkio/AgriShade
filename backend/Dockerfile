# =============================================================================
# AgriShadeNet Central Backend Container (FastAPI + SQLite Relational DB)
# ICT Assignment 3: Database Systems and Cybersecurity
# Author: Azat Madiyev (AITU)
# =============================================================================

FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DATABASE_URL="sqlite:///./data/agrishadenet.db"

# Set working directory inside container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY backend/ /app/backend/
COPY edge/ /app/edge/
COPY security/ /app/security/
COPY agrishadenet_database.sql /app/

# Create persistent storage directory for SQLite database
RUN mkdir -p /app/data

# Seed database during container entry if database does not exist
RUN python -m backend.seed_data

# Expose FastAPI REST service port
EXPOSE 8000

# Health check to ensure API is responsive
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Launch FastAPI service with Uvicorn
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
