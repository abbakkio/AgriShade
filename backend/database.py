"""
AgriShadeNet Central Backend - Database Engine Configuration
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
"""

import os
from sqlalchemy import create_engine, event
from sqlalchemy.orm import declarative_base, sessionmaker

# Database path (can be overridden via environment variable for Docker)
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./agrishadenet.db")

# Enable check_same_thread=False for SQLite in FastAPI multi-threaded runtime
connect_args = {"check_same_thread": False} if "sqlite" in DATABASE_URL else {}

engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
    echo=False  # Set to True for verbose SQL query logging
)

# Enforce foreign key constraints in SQLite
if "sqlite" in DATABASE_URL:
    @event.listens_for(engine, "connect")
    def set_sqlite_pragma(dbapi_connection, connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.execute("PRAGMA journal_mode=WAL")  # Write-Ahead Logging for high concurrency
        cursor.close()

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    """FastAPI Dependency for database session management."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
