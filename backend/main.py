"""
AgriShadeNet Central Telemetry & Diagnostics Backend
FastAPI REST Service with SQLite Relational Persistence and Cybersecurity Defenses
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
Continuity: Assignment 1 & 2 -> Midterm Project Stage 1 -> Assignment 3
"""

from datetime import datetime, timezone
from typing import List, Optional
from fastapi import FastAPI, Depends, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text, func

from .database import engine, Base, get_db
from .models import Farm, Device, DiagnosticScan, AgronomicTreatment, User
from .schemas import (
    UserCreate,
    UserResponse,
    UserLoginRequest,
    UserLoginResponse,
    SyncBatchRequest,
    SyncBatchResponse,
    ScanResponse,
    FarmSummaryResponse,
    SecuritySearchRequest,
)
from .security import (
    verify_edge_device_auth,
    hash_password,
    verify_password,
    generate_secure_token,
)

# Create database tables automatically if they don't exist
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="AgriShadeNet Central Diagnostic Backend API",
    description="Secure edge-to-cloud diagnostic telemetry ingestion, user identity management, and relational farm analytics for precision agriculture.",
    version="1.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS middleware for mobile/web dashboard access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", tags=["System"])
def root():
    """Root metadata endpoint verifying backend status and continuity track."""
    return {
        "system": "AgriShadeNet Central Backend",
        "author": "Azat Madiyev (AITU)",
        "track": "Assignment 1 (Vision) -> Assignment 2 (HCI Edge) -> Midterm (Stage 1 Connected) -> Assignment 3 (Data & Security)",
        "status": "operational",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "endpoints": {
            "docs": "/docs",
            "health": "/health",
            "auth_register": "/api/v1/auth/register",
            "auth_login": "/api/v1/auth/login",
            "users": "/api/v1/users",
            "sync": "/api/v1/sync",
            "scans": "/api/v1/scans",
            "farm_summary": "/api/v1/farms/{farm_id}/summary",
            "security_demo": "/api/v1/security-demo",
        },
    }


@app.get("/health", tags=["System"])
def health_check(db: Session = Depends(get_db)):
    """Health check validating database connectivity and system counts across all entities."""
    try:
        users_count = db.query(User).count()
        farms_count = db.query(Farm).count()
        devices_count = db.query(Device).count()
        scans_count = db.query(DiagnosticScan).count()
        treatments_count = db.query(AgronomicTreatment).count()
        return {
            "status": "healthy",
            "database": "SQLite (WAL mode)",
            "entities": {
                "users": users_count,
                "farms": farms_count,
                "devices": devices_count,
                "scans": scans_count,
                "treatments": treatments_count,
            },
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database connection error: {str(e)}",
        )


# =============================================================================
# 1. USER IDENTITY & CLOUD TELEMETRY AUTHORIZATION
# =============================================================================
@app.post("/api/v1/auth/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED, tags=["Users & Auth"])
def register_user(payload: UserCreate, db: Session = Depends(get_db)):
    """
    Registers an authorized user account (farmer, agronomist, admin) linked to a farm.
    Enables future cloud identity management, RBAC, and multi-tenant farm telemetry routing.
    """
    existing_user = db.query(User).filter(
        (User.username == payload.username) | (User.email == payload.email)
    ).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this username or email already exists.",
        )

    if payload.farm_id is not None:
        farm = db.query(Farm).filter(Farm.id == payload.farm_id).first()
        if not farm:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Associated Farm with ID {payload.farm_id} does not exist.",
            )

    new_user = User(
        username=payload.username,
        email=payload.email,
        hashed_password=hash_password(payload.password),
        full_name=payload.full_name,
        role=payload.role,
        farm_id=payload.farm_id,
        api_token=generate_secure_token(),
        is_active=True,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@app.post("/api/v1/auth/login", response_model=UserLoginResponse, tags=["Users & Auth"])
def login_user(payload: UserLoginRequest, db: Session = Depends(get_db)):
    """Authenticates a user and returns a cloud bearer access token."""
    user = db.query(User).filter(User.username == payload.username).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password.",
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account has been deactivated.",
        )

    # Refresh cloud access token upon login
    user.api_token = generate_secure_token()
    db.commit()

    return UserLoginResponse(
        access_token=user.api_token,
        token_type="bearer",
        user=user,
    )


@app.get("/api/v1/users", response_model=List[UserResponse], tags=["Users & Auth"])
def list_users(farm_id: Optional[int] = None, db: Session = Depends(get_db)):
    """Retrieves all registered users, optionally filtered by farm ID."""
    q = db.query(User)
    if farm_id is not None:
        q = q.filter(User.farm_id == farm_id)
    return q.all()


# =============================================================================
# 2. EDGE TELEMETRY BATCH SYNC ENDPOINT (TASK 3: INSERT & UPDATE)
# =============================================================================
@app.post("/api/v1/sync", response_model=SyncBatchResponse, tags=["Edge Ingestion"])
def sync_edge_scans(
    payload: SyncBatchRequest,
    authenticated_device: Device = Depends(verify_edge_device_auth),
    db: Session = Depends(get_db),
):
    """
    Authenticated ingestion endpoint for on-device edge scanners.
    1. Authenticates device via SHA-256 API Key verification.
    2. Enforces idempotent ingestion (avoids duplicate scans if device retried).
    3. Persists diagnostic scans atomically.
    4. Updates the device's last_sync_at timestamp.
    """
    if authenticated_device.device_serial != payload.device_serial:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cybersecurity Mismatch: Authenticated header does not match payload device_serial.",
        )

    synced_uuids = []
    for item in payload.scans:
        # Check if scan already exists (idempotency check)
        existing = db.query(DiagnosticScan).filter(DiagnosticScan.scan_uuid == item.scan_uuid).first()
        if existing:
            continue

        new_scan = DiagnosticScan(
            scan_uuid=item.scan_uuid,
            device_id=authenticated_device.id,
            crop_type=item.crop_type,
            disease_label=item.disease_label,
            confidence_score=item.confidence_score,
            severity_level=item.severity_level,
            latitude=item.latitude,
            longitude=item.longitude,
            captured_at=item.captured_at,
            synced_at=datetime.now(timezone.utc),
            image_sha256=item.image_sha256,
        )
        db.add(new_scan)
        synced_uuids.append(item.scan_uuid)

    # Update edge device telemetry timestamp
    authenticated_device.last_sync_at = datetime.now(timezone.utc)
    db.commit()

    return SyncBatchResponse(
        status="success",
        synced_count=len(synced_uuids),
        synced_uuids=synced_uuids,
        device_serial=authenticated_device.device_serial,
        server_time=datetime.now(timezone.utc),
    )


# =============================================================================
# 3. PARAMETERIZED QUERY LOOKUP (TASK 3: SELECT LOOKUP)
# =============================================================================
@app.get("/api/v1/scans", response_model=List[ScanResponse], tags=["Analytics & Queries"])
def get_scans(
    crop_type: Optional[str] = Query(None, description="Filter by crop name (e.g., Tomato)"),
    disease_label: Optional[str] = Query(None, description="Filter by disease name"),
    min_confidence: Optional[float] = Query(0.0, ge=0.0, le=1.0, description="Minimum model confidence"),
    severity_level: Optional[str] = Query(None, description="Severity filter: Low, Moderate, Severe, Critical"),
    limit: int = Query(50, ge=1, le=500),
    db: Session = Depends(get_db),
):
    """
    Retrieves filtered diagnostic scans using secure parameterized ORM query execution.
    Fulfills Query 1 (Selective lookup with multi-attribute filtering).
    """
    query = db.query(DiagnosticScan).filter(DiagnosticScan.confidence_score >= min_confidence)

    if crop_type:
        query = query.filter(DiagnosticScan.crop_type.ilike(f"%{crop_type}%"))
    if disease_label:
        query = query.filter(DiagnosticScan.disease_label.ilike(f"%{disease_label}%"))
    if severity_level:
        query = query.filter(DiagnosticScan.severity_level == severity_level.capitalize())

    return query.order_by(DiagnosticScan.captured_at.desc()).limit(limit).all()


# =============================================================================
# 4. RELATIONAL JOIN & AGGREGATION (TASK 3: RELATIONAL JOIN)
# =============================================================================
@app.get("/api/v1/farms/{farm_id}/summary", response_model=FarmSummaryResponse, tags=["Analytics & Queries"])
def get_farm_diagnostic_summary(farm_id: int, db: Session = Depends(get_db)):
    """
    Analytical relational JOIN query linking Farm, Users, Devices, Scans, and Treatments.
    Calculates disease prevalence and prescribes actionable chemical treatment volume.
    Fulfills Query 2 (Relational JOIN with aggregations).
    """
    farm = db.query(Farm).filter(Farm.id == farm_id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found.")

    # Find registered users assigned to this farm
    registered_users = [u.full_name + f" ({u.role})" for u in farm.users]

    # Count active devices
    active_devices = db.query(Device).filter(Device.farm_id == farm_id, Device.is_active == True).count()

    # Relational join: Find all scans recorded by devices assigned to this farm
    scans_query = (
        db.query(DiagnosticScan)
        .join(Device, DiagnosticScan.device_id == Device.id)
        .filter(Device.farm_id == farm_id)
    )
    total_scans = scans_query.count()
    severe_scans = scans_query.filter(DiagnosticScan.severity_level.in_(["Severe", "Critical"])).count()

    # Aggregate disease distribution joined with agronomic treatment protocols
    disease_group = (
        db.query(
            DiagnosticScan.disease_label,
            func.count(DiagnosticScan.id).label("outbreak_count"),
            func.avg(DiagnosticScan.confidence_score).label("avg_confidence"),
            AgronomicTreatment.recommended_treatment,
            AgronomicTreatment.dosage_per_ha_liters,
            AgronomicTreatment.cost_estimate_kzt_per_ha,
        )
        .join(Device, DiagnosticScan.device_id == Device.id)
        .outerjoin(AgronomicTreatment, DiagnosticScan.disease_label == AgronomicTreatment.disease_label)
        .filter(Device.farm_id == farm_id)
        .group_by(DiagnosticScan.disease_label)
        .all()
    )

    protocols = []
    for row in disease_group:
        dosage = row.dosage_per_ha_liters or 0.0
        cost_ha = row.cost_estimate_kzt_per_ha or 0.0
        total_volume_needed = dosage * farm.total_hectares
        total_est_cost = cost_ha * farm.total_hectares

        protocols.append({
            "disease_label": row.disease_label,
            "outbreak_count": row.outbreak_count,
            "avg_confidence": round(float(row.avg_confidence), 3) if row.avg_confidence else 0.0,
            "recommended_treatment": row.recommended_treatment or "Standard Botanical Neem / Monitoring",
            "total_spray_volume_liters": round(total_volume_needed, 2),
            "estimated_total_cost_kzt": round(total_est_cost, 2),
        })

    return FarmSummaryResponse(
        farm_id=farm.id,
        farm_name=farm.farm_name,
        region=farm.region,
        owner_name=farm.owner_name,
        total_hectares=farm.total_hectares,
        registered_users=registered_users,
        active_devices_count=active_devices,
        total_scans_count=total_scans,
        severe_outbreaks_count=severe_scans,
        recommended_protocols=protocols,
    )


# =============================================================================
# 5. CYBERSECURITY DEMONSTRATION: VULNERABLE VS SAFE QUERIES (TASK 4)
# =============================================================================
@app.post("/api/v1/security-demo/unsafe-search", tags=["Cybersecurity Demo"])
def unsafe_search_demo(req: SecuritySearchRequest, db: Session = Depends(get_db)):
    """
    WARNING: INTENTIONALLY VULNERABLE ENDPOINT FOR ICT ASSIGNMENT 3 DEMO.
    Constructs raw SQL via naive string concatenation.
    Vulnerable to SQL Injection attacks such as: ' OR '1'='1
    """
    raw_query = f"SELECT id, crop_type, disease_label, confidence_score, severity_level FROM scans WHERE disease_label = '{req.query}'"
    try:
        result = db.execute(text(raw_query)).fetchall()
        rows = [
            {
                "id": r[0],
                "crop_type": r[1],
                "disease_label": r[2],
                "confidence_score": r[3],
                "severity_level": r[4],
            }
            for r in result
        ]
        return {
            "mode": "UNSAFE_STRING_CONCATENATION",
            "vulnerable": True,
            "executed_sql": raw_query,
            "returned_rows_count": len(rows),
            "data": rows,
            "security_warning": "Attacker payload was interpreted as executable SQL code!",
        }
    except Exception as e:
        return {
            "mode": "UNSAFE_STRING_CONCATENATION",
            "vulnerable": True,
            "executed_sql": raw_query,
            "sql_error": str(e),
        }


@app.post("/api/v1/security-demo/safe-search", tags=["Cybersecurity Demo"])
def safe_search_demo(req: SecuritySearchRequest, db: Session = Depends(get_db)):
    """
    DEFENDED ENDPOINT: Uses Parameterized Prepared Statements via SQLAlchemy ORM.
    Even if attacker injects: ' OR '1'='1
    The input is treated strictly as literal data, completely neutralizing the attack.
    """
    safe_stmt = text(
        "SELECT id, crop_type, disease_label, confidence_score, severity_level "
        "FROM scans WHERE disease_label = :lbl"
    )
    result = db.execute(safe_stmt, {"lbl": req.query}).fetchall()
    rows = [
        {
            "id": r[0],
            "crop_type": r[1],
            "disease_label": r[2],
            "confidence_score": r[3],
            "severity_level": r[4],
        }
        for r in result
    ]
    return {
        "mode": "SAFE_PARAMETERIZED_STATEMENT",
        "vulnerable": False,
        "parameter_bound": req.query,
        "returned_rows_count": len(rows),
        "data": rows,
        "security_note": "Parameterized query treated input as literal string value. Injection prevented.",
    }
