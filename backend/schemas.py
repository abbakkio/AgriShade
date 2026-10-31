"""
Pydantic Schemas for Request Validation and Response Serialization
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
Continuity: Assignment 1 & 2 -> Midterm Project Stage 1 -> Assignment 3
"""

from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field, field_validator


# =============================================================================
# USER SCHEMAS (USER ENTITY WITH RELATION TO FARM FOR CLOUD TELEMETRY)
# =============================================================================
class UserCreate(BaseModel):
    """Payload to register a new authorized user linked to a farm."""
    username: str = Field(..., min_length=3, max_length=50, description="Unique account handle")
    email: str = Field(..., description="Official contact email")
    password: str = Field(..., min_length=6, description="Plaintext password to be hashed")
    full_name: str = Field(..., max_length=100, description="Full legal name of user")
    role: str = Field("agronomist", description="Role: farm_owner, agronomist, operator, admin")
    farm_id: Optional[int] = Field(None, description="Associated agricultural enterprise ID")

    @field_validator("role")
    @classmethod
    def validate_role(cls, v: str) -> str:
        valid_roles = {"farm_owner", "agronomist", "operator", "admin"}
        if v.lower() not in valid_roles:
            raise ValueError(f"role must be one of {valid_roles}")
        return v.lower()


class UserResponse(BaseModel):
    """Public serialized user account record."""
    id: int
    username: str
    email: str
    full_name: str
    role: str
    farm_id: Optional[int]
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class UserLoginRequest(BaseModel):
    """Credentials for cloud web/mobile authentication."""
    username: str
    password: str


class UserLoginResponse(BaseModel):
    """Token payload returned upon successful cloud login."""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


# =============================================================================
# EDGE TELEMETRY & SCAN SCHEMAS
# =============================================================================
class ScanPayload(BaseModel):
    """Payload representing a single diagnostic scan captured on edge device."""
    scan_uuid: str = Field(..., description="Unique UUIDv4 identifier generated on edge")
    crop_type: str = Field(..., max_length=50, description="Crop name (e.g., Tomato, Potato)")
    disease_label: str = Field(..., max_length=100, description="Pathological diagnosis label")
    confidence_score: float = Field(..., ge=0.0, le=1.0, description="Model classification confidence [0.0 - 1.0]")
    severity_level: str = Field(..., description="Severity classification: Low, Moderate, Severe, Critical")
    latitude: float = Field(..., ge=-90.0, le=90.0, description="GPS Latitude")
    longitude: float = Field(..., ge=-180.0, le=180.0, description="GPS Longitude")
    captured_at: datetime = Field(..., description="ISO 8601 timestamp of field capture")
    image_sha256: str = Field(..., min_length=64, max_length=64, description="SHA-256 hash of leaf image")

    @field_validator("severity_level")
    @classmethod
    def validate_severity(cls, v: str) -> str:
        valid_levels = {"Healthy", "Low", "Moderate", "Severe", "Critical"}
        if v.capitalize() not in valid_levels:
            raise ValueError(f"severity_level must be one of {valid_levels}")
        return v.capitalize()


class SyncBatchRequest(BaseModel):
    """Batch upload payload sent by edge device during sync."""
    device_serial: str = Field(..., max_length=50, description="Unique serial identifier of edge unit")
    scans: List[ScanPayload] = Field(..., description="List of buffered diagnostic scans")


class SyncBatchResponse(BaseModel):
    """Response returned upon successful batch sync."""
    status: str
    synced_count: int
    synced_uuids: List[str]
    device_serial: str
    server_time: datetime


class ScanResponse(BaseModel):
    """Serialized scan record returned from database queries."""
    id: int
    scan_uuid: str
    device_id: int
    crop_type: str
    disease_label: str
    confidence_score: float
    severity_level: str
    latitude: float
    longitude: float
    captured_at: datetime
    synced_at: datetime
    image_sha256: str

    class Config:
        from_attributes = True


class FarmSummaryResponse(BaseModel):
    """Aggregated analytical response joining Farm, Users, Devices, Scans, and Treatments."""
    farm_id: int
    farm_name: str
    region: str
    owner_name: str
    total_hectares: float
    registered_users: List[str]
    active_devices_count: int
    total_scans_count: int
    severe_outbreaks_count: int
    recommended_protocols: List[dict]


class SecuritySearchRequest(BaseModel):
    """Payload to demonstrate input query handling and injection vulnerability."""
    query: str = Field(..., max_length=200, description="Search query string")
