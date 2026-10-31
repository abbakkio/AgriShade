"""
Edge Local SQLite Store-and-Forward Buffer
Enables 100% offline crop diagnostics on edge devices without internet connectivity.
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
"""

import sqlite3
import os
from datetime import datetime, timezone
from typing import List, Dict, Any

EDGE_DB_PATH = os.getenv("EDGE_DB_PATH", "edge_local_buffer.db")


def init_edge_db(db_path: str = EDGE_DB_PATH) -> None:
    """Initializes local SQLite database and buffered_scans table on edge hardware."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS buffered_scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scan_uuid TEXT UNIQUE NOT NULL,
        crop_type TEXT NOT NULL,
        disease_label TEXT NOT NULL,
        confidence_score REAL NOT NULL,
        severity_level TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        captured_at TEXT NOT NULL,
        image_sha256 TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'PENDING',
        synced_at TEXT
    );
    """)
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_sync_status ON buffered_scans(sync_status);")
    conn.commit()
    conn.close()


def enqueue_scan(scan_dict: Dict[str, Any], db_path: str = EDGE_DB_PATH) -> bool:
    """Queues a newly captured on-device diagnosis into local offline storage."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    try:
        cursor.execute("""
        INSERT INTO buffered_scans (
            scan_uuid, crop_type, disease_label, confidence_score,
            severity_level, latitude, longitude, captured_at,
            image_sha256, sync_status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')
        """, (
            scan_dict["scan_uuid"],
            scan_dict["crop_type"],
            scan_dict["disease_label"],
            float(scan_dict["confidence_score"]),
            scan_dict["severity_level"],
            float(scan_dict["latitude"]),
            float(scan_dict["longitude"]),
            scan_dict["captured_at"],
            scan_dict["image_sha256"],
        ))
        conn.commit()
        return True
    except sqlite3.IntegrityError:
        # Already enqueued
        return False
    finally:
        conn.close()


def get_pending_scans(db_path: str = EDGE_DB_PATH, limit: int = 50) -> List[Dict[str, Any]]:
    """Fetches scans that have not yet been synced to central FastAPI backend."""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("""
        SELECT scan_uuid, crop_type, disease_label, confidence_score,
               severity_level, latitude, longitude, captured_at, image_sha256
        FROM buffered_scans
        WHERE sync_status = 'PENDING'
        ORDER BY id ASC
        LIMIT ?
    """, (limit,))
    rows = cursor.fetchall()
    results = [dict(row) for row in rows]
    conn.close()
    return results


def mark_scans_synced(uuids: List[str], db_path: str = EDGE_DB_PATH) -> int:
    """Updates sync status of successfully uploaded scans to 'SYNCED'."""
    if not uuids:
        return 0
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    now_iso = datetime.now(timezone.utc).isoformat()
    placeholders = ",".join(["?"] * len(uuids))
    cursor.execute(f"""
        UPDATE buffered_scans
        SET sync_status = 'SYNCED', synced_at = ?
        WHERE scan_uuid IN ({placeholders})
    """, [now_iso] + uuids)
    count = cursor.rowcount
    conn.commit()
    conn.close()
    return count


def get_buffer_stats(db_path: str = EDGE_DB_PATH) -> Dict[str, int]:
    """Returns total, pending, and synced scan counts from edge storage."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT sync_status, COUNT(*) FROM buffered_scans GROUP BY sync_status")
    counts = dict(cursor.fetchall())
    conn.close()
    return {
        "pending": counts.get("PENDING", 0),
        "synced": counts.get("SYNCED", 0),
        "total": sum(counts.values()),
    }
