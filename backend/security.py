"""
Cybersecurity Utilities: Edge Device Authentication & Cryptographic Hashing
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
Continuity: Assignment 1 & 2 -> Midterm Project Stage 1 -> Assignment 3
"""

import hashlib
import hmac
import secrets
from typing import Optional
from fastapi import Header, HTTPException, status, Depends
from sqlalchemy.orm import Session

from .database import get_db
from .models import Device, User


def hash_token(token: str) -> str:
    """Computes SHA-256 hash of a plaintext token or secret."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def hash_password(password: str) -> str:
    """Computes SHA-256 digest of a user password with a fixed pepper."""
    salted = f"agrishadenet_salt_{password}".encode("utf-8")
    return hashlib.sha256(salted).hexdigest()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plaintext password against stored hash using constant-time comparison."""
    return hmac.compare_digest(hash_password(plain_password), hashed_password)


def generate_secure_token() -> str:
    """Generates a cryptographically random 32-byte hex token for cloud API access."""
    return secrets.token_hex(32)


def verify_edge_device_auth(
    x_api_key: Optional[str] = Header(None, alias="X-API-Key"),
    x_device_serial: Optional[str] = Header(None, alias="X-Device-Serial"),
    db: Session = Depends(get_db)
) -> Device:
    """
    FastAPI security dependency that authenticates edge requests:
    1. Checks for presence of X-API-Key and X-Device-Serial headers.
    2. Hashes incoming key with SHA-256.
    3. Looks up the device and performs constant-time comparison against stored hash.
    4. Enforces active device status.
    """
    if not x_api_key or not x_device_serial:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Cybersecurity Protection: Missing 'X-API-Key' or 'X-Device-Serial' authentication headers.",
            headers={"WWW-Authenticate": "ApiKey"},
        )

    # Query device by serial
    device = db.query(Device).filter(Device.device_serial == x_device_serial).first()
    if not device:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Cybersecurity Protection: Device serial is unrecognized.",
            headers={"WWW-Authenticate": "ApiKey"},
        )

    if not device.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cybersecurity Protection: Device access has been revoked or deactivated.",
        )

    # Compute incoming key hash and compare using constant-time comparison (prevents timing attacks)
    incoming_hash = hash_token(x_api_key)
    if not hmac.compare_digest(incoming_hash, device.api_key_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Cybersecurity Protection: Invalid device authentication credentials.",
            headers={"WWW-Authenticate": "ApiKey"},
        )

    return device
