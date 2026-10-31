"""
Demonstration Queries for Assignment 3
Executes the 3 required queries against the mini-database and displays formatted outputs.
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
Continuity: Assignment 1 & 2 -> Midterm Project Stage 1 -> Assignment 3
"""

from datetime import datetime, timezone
from sqlalchemy import text
from .database import engine, SessionLocal
from .models import Farm, Device, DiagnosticScan, AgronomicTreatment, User


def print_banner(title: str):
    print("\n" + "=" * 100)
    print(f" {title}")
    print("=" * 100)


def run_query_1_selective_lookup():
    """
    QUERY 1: Selective Lookup (SELECT with Multi-Condition Filter)
    Purpose: A plant protection specialist or regional inspector queries all active high-confidence
             (confidence >= 0.90) disease infections of 'Severe' or 'Critical' severity.
    """
    print_banner("QUERY 1: High-Confidence Severe Outbreak Detection (SELECT Lookup)")
    raw_sql = """
    SELECT 
        s.scan_uuid,
        s.crop_type,
        s.disease_label,
        ROUND(s.confidence_score * 100, 1) AS confidence_pct,
        s.severity_level,
        s.latitude,
        s.longitude,
        s.captured_at
    FROM scans s
    WHERE s.confidence_score >= 0.90 
      AND s.severity_level IN ('Severe', 'Critical')
    ORDER BY s.confidence_score DESC;
    """
    print(f"SQL EXECUTED:\n{raw_sql.strip()}\n")
    print(f"{'SCAN UUID':<38} | {'CROP':<8} | {'CONF':<6} | {'SEVERITY':<8} | {'DISEASE LABEL':<38}")
    print("-" * 110)

    with engine.connect() as conn:
        result = conn.execute(text(raw_sql))
        for row in result:
            print(f"{row[0]:<38} | {row[1]:<8} | {row[3]}%  | {row[4]:<8} | {row[2]:<38}")


def run_query_2_relational_join():
    """
    QUERY 2: Relational Multi-Entity JOIN with User Responsibility & Agronomic Calculation
    Purpose: Farm management reporting query joining Users, Farms, Devices, Scans, and Treatments.
             Links the designated agronomist/user, the farm enterprise, the edge device, and the
             pathology to calculate total fungicide volume and costs in KZT.
    """
    print_banner("QUERY 2: Farm Diagnostic Aggregation & Chemical Dosage Protocol (5-Table JOIN with Users)")
    raw_sql = """
    SELECT 
        u.full_name AS assigned_specialist,
        u.role AS user_role,
        f.farm_name,
        f.region,
        f.total_hectares,
        d.device_serial,
        s.disease_label,
        t.recommended_treatment,
        ROUND(t.dosage_per_ha_liters * f.total_hectares, 1) AS total_liters_needed,
        ROUND(t.cost_estimate_kzt_per_ha * f.total_hectares, 0) AS total_treatment_cost_kzt
    FROM users u
    JOIN farms f ON u.farm_id = f.id
    JOIN devices d ON d.farm_id = f.id
    JOIN scans s ON s.device_id = d.id
    JOIN treatments t ON s.disease_label = t.disease_label
    WHERE s.severity_level != 'Healthy'
    ORDER BY total_treatment_cost_kzt DESC;
    """
    print(f"SQL EXECUTED:\n{raw_sql.strip()}\n")
    print(f"{'ASSIGNED SPECIALIST':<20} | {'ROLE':<12} | {'FARM NAME':<24} | {'REGION':<10} | {'DISEASE':<22} | {'LITERS':<8} | {'TOTAL COST (KZT)':<16}")
    print("-" * 130)

    with engine.connect() as conn:
        result = conn.execute(text(raw_sql))
        for row in result:
            print(f"{row[0][:19]:<20} | {row[1]:<12} | {row[2][:23]:<24} | {row[3]:<10} | {row[6][:21]:<22} | {row[8]:<8} | {int(row[9]):>12,d} KZT")


def run_query_3_insert_and_update():
    """
    QUERY 3: Data Ingestion & State Update (INSERT & UPDATE)
    Purpose: Simulates an edge device syncing a newly detected crop lesion to the cloud:
             1. INSERTs new scan record into `scans`.
             2. UPDATEs the corresponding `devices.last_sync_at` timestamp.
    """
    print_banner("QUERY 3: Edge Sync Ingestion & Telemetry Update (INSERT & UPDATE)")
    new_uuid = "9999aaaa-8888-bbbb-7777-ccccdddd1111"
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

    insert_sql = """
    INSERT INTO scans (
        scan_uuid, device_id, crop_type, disease_label, 
        confidence_score, severity_level, latitude, longitude, 
        captured_at, synced_at, image_sha256
    ) VALUES (
        :uuid, 1, 'Tomato', 'Tomato Late Blight (Phytophthora infestans)',
        0.978, 'Critical', 51.1745, 71.4580,
        :captured, :synced, 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
    );
    """
    update_sql = """
    UPDATE devices 
    SET last_sync_at = :synced 
    WHERE id = 1;
    """

    print(f"1. INSERT STATEMENT:\n{insert_sql.strip()}\n")
    print(f"2. UPDATE STATEMENT:\n{update_sql.strip()}\n")

    with engine.begin() as conn:
        conn.execute(text("DELETE FROM scans WHERE scan_uuid = :uuid"), {"uuid": new_uuid})
        conn.execute(text(insert_sql), {"uuid": new_uuid, "captured": now_iso, "synced": now_iso})
        conn.execute(text(update_sql), {"synced": now_iso})

    # Verify results
    with engine.connect() as conn:
        scan_verify = conn.execute(
            text("SELECT scan_uuid, disease_label, confidence_score, synced_at FROM scans WHERE scan_uuid = :uuid"),
            {"uuid": new_uuid}
        ).fetchone()
        device_verify = conn.execute(
            text("SELECT device_serial, last_sync_at FROM devices WHERE id = 1")
        ).fetchone()

        print("VERIFICATION RESULTS:")
        print(f"  [✓] Inserted Scan: {scan_verify[0]} | {scan_verify[1]} | Conf: {scan_verify[2]} | Synced: {scan_verify[3]}")
        print(f"  [✓] Updated Device: Serial={device_verify[0]} | LastSyncAt={device_verify[1]}")


def run_all_queries():
    run_query_1_selective_lookup()
    run_query_2_relational_join()
    run_query_3_insert_and_update()
    print("\n[✓] All 3 assignment queries executed successfully against the database!\n")


if __name__ == "__main__":
    run_all_queries()
