"""
AgriShadeNet Relational Database Models (SQLAlchemy ORM)
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
Continuity: Assignment 1 & 2 -> Midterm Project Stage 1 -> Assignment 3
"""

from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship

from .database import Base


def utc_now():
    return datetime.now(timezone.utc)


class User(Base):
    """
    Represents an authorized human user (farm owner, field agronomist, or cloud operator).
    Enables future cloud identity management, RBAC, and multi-tenant farm telemetry routing.
    """
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=False, index=True)
    hashed_password = Column(String(128), nullable=False)
    full_name = Column(String(100), nullable=False)
    role = Column(String(20), nullable=False, default="agronomist")  # farm_owner, agronomist, operator, admin
    farm_id = Column(Integer, ForeignKey("farms.id", ondelete="SET NULL"), nullable=True, index=True)
    api_token = Column(String(64), unique=True, nullable=True)  # Future cloud bearer token
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=utc_now, nullable=False)

    # Relationships
    farm = relationship("Farm", back_populates="users")

    def __repr__(self):
        return f"<User id={self.id} username='{self.username}' role='{self.role}' farm_id={self.farm_id}>"


class Farm(Base):
    """Represents an agricultural enterprise or smallholder farm plot."""
    __tablename__ = "farms"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    farm_name = Column(String(100), nullable=False)
    owner_name = Column(String(100), nullable=False)
    region = Column(String(50), nullable=False, index=True)
    contact_phone = Column(String(20), nullable=False)
    total_hectares = Column(Float, nullable=False, default=10.0)
    created_at = Column(DateTime, default=utc_now, nullable=False)

    # Relationships
    users = relationship("User", back_populates="farm")
    devices = relationship("Device", back_populates="farm", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Farm id={self.id} name='{self.farm_name}' region='{self.region}'>"


class Device(Base):
    """Represents an edge IoT handheld diagnostic scanner (AgriShadeNet Edge Node)."""
    __tablename__ = "devices"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    device_serial = Column(String(50), unique=True, nullable=False, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id", ondelete="CASCADE"), nullable=False)
    hardware_model = Column(String(50), nullable=False, default="Raspberry Pi 4 / ARM Cortex-A72")
    firmware_version = Column(String(20), nullable=False, default="v2.4.1")
    api_key_hash = Column(String(64), nullable=False)  # SHA-256 hash of edge device token
    is_active = Column(Boolean, default=True, nullable=False)
    last_sync_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=utc_now, nullable=False)

    # Relationships
    farm = relationship("Farm", back_populates="devices")
    scans = relationship("DiagnosticScan", back_populates="device", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Device id={self.id} serial='{self.device_serial}' farm_id={self.farm_id}>"


class DiagnosticScan(Base):
    """Represents an in-field crop pathology diagnostic scan captured on edge device."""
    __tablename__ = "scans"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    scan_uuid = Column(String(36), unique=True, nullable=False, index=True)
    device_id = Column(Integer, ForeignKey("devices.id", ondelete="CASCADE"), nullable=False)
    crop_type = Column(String(50), nullable=False, index=True)
    disease_label = Column(String(100), nullable=False, index=True)
    confidence_score = Column(Float, nullable=False)
    severity_level = Column(String(20), nullable=False, index=True)  # Low, Moderate, Severe, Critical
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    captured_at = Column(DateTime, nullable=False)
    synced_at = Column(DateTime, default=utc_now, nullable=False)
    image_sha256 = Column(String(64), nullable=False)  # Cryptographic hash to verify image integrity

    # Relationships
    device = relationship("Device", back_populates="scans")

    __table_args__ = (
        Index("idx_scans_crop_disease", "crop_type", "disease_label"),
        Index("idx_scans_severity_confidence", "severity_level", "confidence_score"),
    )

    def __repr__(self):
        return f"<DiagnosticScan uuid='{self.scan_uuid}' disease='{self.disease_label}' conf={self.confidence_score:.3f}>"


class AgronomicTreatment(Base):
    """Agronomic clinical prescriptions, fungicide dosage rules, and spray protocols."""
    __tablename__ = "treatments"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    disease_label = Column(String(100), unique=True, nullable=False, index=True)
    recommended_treatment = Column(String(150), nullable=False)
    active_ingredient = Column(String(100), nullable=False)
    dosage_per_ha_liters = Column(Float, nullable=False)
    spray_interval_days = Column(Integer, nullable=False)
    pre_harvest_interval_days = Column(Integer, nullable=False)
    cost_estimate_kzt_per_ha = Column(Float, nullable=False)

    def __repr__(self):
        return f"<Treatment disease='{self.disease_label}' dose={self.dosage_per_ha_liters}L/ha>"
