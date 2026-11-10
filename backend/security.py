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
    authorization: Optional[str] = Header(None, alias="Authorization"),
    db: Session = Depends(get_db)
) -> Device:
    """
    FastAPI security dependency that authenticates edge or mobile requests:
    1. If a valid User Bearer token is provided, binds the session to the user's mobile device.
    2. Otherwise checks for presence of X-API-Key and X-Device-Serial edge headers.
    3. Hashes incoming key with SHA-256 and validates against registered devices.
    """
    # Path A: Authenticated Mobile User via Cloud Bearer Token
    if authorization and "Bearer " in authorization:
        token = authorization.split("Bearer ")[-1].strip()
        user = db.query(User).filter(User.api_token == token).first()
        if user and user.is_active:
            serial = x_device_serial or f"AGRI-USER-{user.id}"
            device = db.query(Device).filter(Device.device_serial == serial).first()
            if not device:
                from .models import Farm
                default_farm = db.query(Farm).first()
                farm_id = user.farm_id or (default_farm.id if default_farm else None)
                if not farm_id and default_farm is None:
                    # Create default pilot farm if none exists
                    farm = Farm(
                        farm_name="AgriShade Pilot Plots",
                        owner_name=user.full_name,
                        region="Zhambyl",
                        total_hectares=50.0
                    )
                    db.add(farm)
                    db.commit()
                    db.refresh(farm)
                    farm_id = farm.id

                device = Device(
                    device_serial=serial,
                    farm_id=farm_id or 1,
                    hardware_model="Mobile iOS App",
                    firmware_version="v2.5.0",
                    api_key_hash=hash_token(x_api_key or "mobile_user_key"),
                    is_active=True,
                )
                db.add(device)
                db.commit()
                db.refresh(device)
            return device

    # Path B: Standalone Edge Device with Hardware API Key
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
