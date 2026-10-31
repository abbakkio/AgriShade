"""
AgriShadeNet On-Device Sync Client
Handles offline buffering and authenticated store-and-forward batch telemetry synchronization.
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
"""

import os
import sys
import time
import argparse
import requests
from typing import Dict, Any, List

from .edge_db import init_edge_db, get_pending_scans, mark_scans_synced, get_buffer_stats
from .edge_scanner import capture_field_scan

# Edge Device Credentials (matches seed data: AGRI-EDGE-AKM-001)
DEFAULT_BACKEND_URL = os.getenv("AGRI_BACKEND_URL", "http://localhost:8000")
DEFAULT_DEVICE_SERIAL = os.getenv("AGRI_DEVICE_SERIAL", "AGRI-EDGE-AKM-001")
DEFAULT_API_KEY = os.getenv("AGRI_API_KEY", "akm_key_001_secret")


class AgriShadeNetEdgeClient:
    """Manages on-device diagnostics and cloud telemetry synchronization."""

    def __init__(
        self,
        backend_url: str = DEFAULT_BACKEND_URL,
        device_serial: str = DEFAULT_DEVICE_SERIAL,
        api_key: str = DEFAULT_API_KEY,
    ):
        self.backend_url = backend_url.rstrip("/")
        self.device_serial = device_serial
        self.api_key = api_key
        init_edge_db()

    def scan_offline(self, count: int = 1):
        """Simulates field diagnostics performed without cellular connection."""
        print(f"\n[*] [EDGE DEVICE: {self.device_serial}] Capturing {count} in-field plant scan(s) offline...")
        for i in range(count):
            scan = capture_field_scan()
            time.sleep(0.3)
        stats = get_buffer_stats()
        print(f"[✓] Scans stored in local SQLite buffer. Buffer Status: {stats['pending']} PENDING | {stats['synced']} SYNCED\n")

    def sync_to_backend(self) -> bool:
        """Uploads all pending offline scans to central FastAPI backend."""
        pending = get_pending_scans(limit=100)
        if not pending:
            print("[i] [SYNC MANAGER] No pending scans in local buffer. Everything up to date.")
            return True

        print(f"\n[*] [SYNC MANAGER] Found {len(pending)} pending scan(s) in local buffer.")
        print(f"[*] Connecting to Central FastAPI Backend at {self.backend_url}/api/v1/sync ...")

        headers = {
            "Content-Type": "application/json",
            "X-Device-Serial": self.device_serial,
            "X-API-Key": self.api_key,
        }
        payload = {
            "device_serial": self.device_serial,
            "scans": pending,
        }

        try:
            resp = requests.post(
                f"{self.backend_url}/api/v1/sync",
                json=payload,
                headers=headers,
                timeout=10,
            )

            if resp.status_code == 200:
                data = resp.json()
                synced_uuids = data.get("synced_uuids", [])
                marked = mark_scans_synced(synced_uuids)
                print(f"[✓] [SYNC SUCCESS] Ingested {data.get('synced_count')} scans into central database!")
                print(f"[✓] Local offline buffer updated: {marked} records marked as 'SYNCED'.")
                stats = get_buffer_stats()
                print(f"[✓] Buffer Status: {stats['pending']} PENDING | {stats['synced']} SYNCED\n")
                return True
            else:
                print(f"[!] [SYNC FAILED] HTTP {resp.status_code}: {resp.text}")
                return False

        except requests.exceptions.ConnectionError:
            print(f"[!] [OFFLINE MODE] Cannot reach central backend at {self.backend_url}.")
            print("    Scans remain safely preserved in local SQLite buffer for next connection window.\n")
            return False
        except Exception as e:
            print(f"[!] [ERROR] Sync exception: {str(e)}\n")
            return False

    def print_status(self):
        """Displays status of local SQLite queue."""
        stats = get_buffer_stats()
        print("\n" + "=" * 60)
        print(f" AgriShadeNet Edge Node: {self.device_serial}")
        print("=" * 60)
        print(f" Local SQLite Buffer File: edge_local_buffer.db")
        print(f" Pending Scans (Offline):  {stats['pending']}")
        print(f" Synced Scans (Cloud):     {stats['synced']}")
        print(f" Total Local Records:      {stats['total']}")
        print("=" * 60 + "\n")


def main():
    parser = argparse.ArgumentParser(description="AgriShadeNet Edge Node Diagnostic Client")
    parser.add_argument("--scan", type=int, default=0, help="Capture N crop scans offline into local buffer")
    parser.add_argument("--sync", action="store_true", help="Sync pending scans from local buffer to FastAPI backend")
    parser.add_argument("--status", action="store_true", help="Display local buffer statistics")
    parser.add_argument("--auto", action="store_true", help="Demonstrate full cycle: 3 offline scans -> automatic cloud sync")
    parser.add_argument("--url", type=str, default=DEFAULT_BACKEND_URL, help="FastAPI backend URL")
    args = parser.parse_args()

    client = AgriShadeNetEdgeClient(backend_url=args.url)

    if args.status:
        client.print_status()
    elif args.scan > 0:
        client.scan_offline(args.scan)
    elif args.sync:
        client.sync_to_backend()
    elif args.auto:
        print("[*] Running automated end-to-end Demonstration:")
        print("    Step 1: Capture 3 scans offline on device")
        client.scan_offline(3)
        client.print_status()
        print("    Step 2: Sync buffered scans to central FastAPI backend")
        client.sync_to_backend()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
