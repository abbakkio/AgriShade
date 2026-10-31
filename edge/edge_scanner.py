"""
On-Device Pathology Scanner Simulator
Runs edge diagnostics and records findings directly to local offline SQLite buffer.
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
"""

import hashlib
import uuid
import random
from datetime import datetime, timezone
from typing import Dict, Any, Optional

from .edge_db import enqueue_scan, init_edge_db

# Real disease taxonomy matching AgriShadeNet neural network classes
DISEASE_CATALOG = [
    {"crop": "Tomato", "disease": "Tomato Late Blight (Phytophthora infestans)", "severity": "Critical"},
    {"crop": "Tomato", "disease": "Tomato Early Blight (Alternaria solani)", "severity": "Moderate"},
    {"crop": "Tomato", "disease": "Tomato Yellow Leaf Curl Virus", "severity": "Critical"},
    {"crop": "Tomato", "disease": "Tomato Septoria Leaf Spot", "severity": "Moderate"},
    {"crop": "Tomato", "disease": "Tomato Bacterial Spot (Xanthomonas)", "severity": "Severe"},
    {"crop": "Tomato", "disease": "Healthy Foliage", "severity": "Healthy"},
    {"crop": "Potato", "disease": "Potato Late Blight (Phytophthora infestans)", "severity": "Critical"},
    {"crop": "Potato", "disease": "Potato Early Blight (Alternaria grandis)", "severity": "Moderate"},
    {"crop": "Potato", "disease": "Healthy Foliage", "severity": "Healthy"},
    {"crop": "Pepper", "disease": "Pepper Bell Bacterial Spot", "severity": "Severe"},
]


def capture_field_scan(
    crop_type: Optional[str] = None,
    disease_label: Optional[str] = None,
    latitude: float = 51.1694,
    longitude: float = 71.4491,
    image_bytes: Optional[bytes] = None,
) -> Dict[str, Any]:
    """
    Simulates or executes an edge optical scan:
    - Generates cryptographic SHA-256 integrity hash.
    - Determines disease class and confidence score.
    - Saves locally to offline SQLite buffer.
    """
    init_edge_db()

    if disease_label:
        entry = next((d for d in DISEASE_CATALOG if d["disease"] == disease_label), None)
        if not entry:
            entry = {"crop": crop_type or "Tomato", "disease": disease_label, "severity": "Moderate"}
    else:
        entry = random.choice(DISEASE_CATALOG)

    if image_bytes is None:
        # Create a synthetic image hash simulating camera frame capture
        raw_token = f"frame_{datetime.now(timezone.utc).isoformat()}_{random.random()}".encode("utf-8")
        image_sha256 = hashlib.sha256(raw_token).hexdigest()
    else:
        image_sha256 = hashlib.sha256(image_bytes).hexdigest()

    # Generate realistic model confidence score
    confidence = round(random.uniform(0.88, 0.99) if entry["severity"] != "Healthy" else random.uniform(0.95, 0.995), 3)

    # Slight GPS jitter simulating walking across the farm plot
    lat = round(latitude + random.uniform(-0.005, 0.005), 5)
    lon = round(longitude + random.uniform(-0.005, 0.005), 5)

    scan_data = {
        "scan_uuid": str(uuid.uuid4()),
        "crop_type": entry["crop"],
        "disease_label": entry["disease"],
        "confidence_score": confidence,
        "severity_level": entry["severity"],
        "latitude": lat,
        "longitude": lon,
        "captured_at": datetime.now(timezone.utc).isoformat(),
        "image_sha256": image_sha256,
    }

    # Store in local offline buffer
    enqueued = enqueue_scan(scan_data)
    if enqueued:
        print(f"[*] [EDGE-SCANNER] Offline Scan Enqueued: {scan_data['crop_type']} -> {scan_data['disease_label']} ({scan_data['confidence_score']*100:.1f}%) [UUID: {scan_data['scan_uuid'][:8]}...]")
    return scan_data


if __name__ == "__main__":
    print("[*] Generating 3 test offline scans on device...")
    for _ in range(3):
        capture_field_scan()
