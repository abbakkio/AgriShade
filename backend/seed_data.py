"""
Seed Script: Populates Mini-Database with 10 Realistic Rows per Table
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
Continuity: Assignment 1 & 2 -> Midterm Project Stage 1 -> Assignment 3
"""

from datetime import datetime, timezone, timedelta
from sqlalchemy.orm import Session

from .database import engine, Base, SessionLocal
from .models import Farm, Device, DiagnosticScan, AgronomicTreatment, User
from .security import hash_token, hash_password, generate_secure_token


def seed_database():
    """Initializes tables and populates at least 10 realistic records per table."""
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()

    # Clear existing data in reverse dependency order
    db.query(DiagnosticScan).delete()
    db.query(Device).delete()
    db.query(User).delete()
    db.query(Farm).delete()
    db.query(AgronomicTreatment).delete()
    db.commit()

    print("[*] Seeding 10 Agronomic Treatment Protocols...")
    treatments_data = [
        AgronomicTreatment(
            disease_label="Tomato Late Blight (Phytophthora infestans)",
            recommended_treatment="Mancozeb 75% WP + Metalaxyl 8%",
            active_ingredient="Metalaxyl-M & Mancozeb",
            dosage_per_ha_liters=2.5,
            spray_interval_days=7,
            pre_harvest_interval_days=14,
            cost_estimate_kzt_per_ha=18500.0,
        ),
        AgronomicTreatment(
            disease_label="Tomato Early Blight (Alternaria solani)",
            recommended_treatment="Chlorothalonil 720 SC",
            active_ingredient="Chlorothalonil",
            dosage_per_ha_liters=2.0,
            spray_interval_days=10,
            pre_harvest_interval_days=7,
            cost_estimate_kzt_per_ha=14200.0,
        ),
        AgronomicTreatment(
            disease_label="Tomato Yellow Leaf Curl Virus",
            recommended_treatment="Imidacloprid 200 SL (Vector Control) + Silver Reflective Mulch",
            active_ingredient="Imidacloprid (Whitefly vector suppression)",
            dosage_per_ha_liters=0.75,
            spray_interval_days=14,
            pre_harvest_interval_days=21,
            cost_estimate_kzt_per_ha=22000.0,
        ),
        AgronomicTreatment(
            disease_label="Tomato Septoria Leaf Spot",
            recommended_treatment="Copper Oxychloride 50% WP",
            active_ingredient="Copper Oxychloride",
            dosage_per_ha_liters=3.0,
            spray_interval_days=7,
            pre_harvest_interval_days=5,
            cost_estimate_kzt_per_ha=11800.0,
        ),
        AgronomicTreatment(
            disease_label="Tomato Bacterial Spot (Xanthomonas)",
            recommended_treatment="Streptomycin Sulfate + Copper Hydroxide",
            active_ingredient="Copper Hydroxide & Streptomycin",
            dosage_per_ha_liters=2.2,
            spray_interval_days=7,
            pre_harvest_interval_days=10,
            cost_estimate_kzt_per_ha=26500.0,
        ),
        AgronomicTreatment(
            disease_label="Potato Late Blight (Phytophthora infestans)",
            recommended_treatment="Cyazofamid 400 SC (Ranman)",
            active_ingredient="Cyazofamid",
            dosage_per_ha_liters=0.25,
            spray_interval_days=7,
            pre_harvest_interval_days=7,
            cost_estimate_kzt_per_ha=21000.0,
        ),
        AgronomicTreatment(
            disease_label="Potato Early Blight (Alternaria grandis)",
            recommended_treatment="Azoxystrobin 250 SC (Quadris)",
            active_ingredient="Azoxystrobin",
            dosage_per_ha_liters=0.8,
            spray_interval_days=12,
            pre_harvest_interval_days=14,
            cost_estimate_kzt_per_ha=19400.0,
        ),
        AgronomicTreatment(
            disease_label="Pepper Bell Bacterial Spot",
            recommended_treatment="Kasugamycin 2% SL (Kasumin)",
            active_ingredient="Kasugamycin",
            dosage_per_ha_liters=1.5,
            spray_interval_days=8,
            pre_harvest_interval_days=7,
            cost_estimate_kzt_per_ha=24800.0,
        ),
        AgronomicTreatment(
            disease_label="Tomato Target Spot (Corynespora casiicola)",
            recommended_treatment="Boscalid + Pyraclostrobin (Cabrio Top)",
            active_ingredient="Boscalid & Pyraclostrobin",
            dosage_per_ha_liters=1.2,
            spray_interval_days=10,
            pre_harvest_interval_days=10,
            cost_estimate_kzt_per_ha=23500.0,
        ),
        AgronomicTreatment(
            disease_label="Healthy Foliage",
            recommended_treatment="Routine Organic Micronutrient Foliar Spray (Zinc + Boron)",
            active_ingredient="Foliar Micronutrient Complex",
            dosage_per_ha_liters=1.0,
            spray_interval_days=21,
            pre_harvest_interval_days=0,
            cost_estimate_kzt_per_ha=6500.0,
        ),
    ]
    db.add_all(treatments_data)
    db.commit()

    print("[*] Seeding 10 Regional Agricultural Enterprises (Farms)...")
    farms_data = [
        Farm(farm_name="Baiterek Agro Agrocomplex", owner_name="Nurlan Akhmetov", region="Akmola", contact_phone="+7-716-255-0101", total_hectares=120.0),
        Farm(farm_name="Zhetysu Green Valley", owner_name="Aigerim Sadykova", region="Almaty", contact_phone="+7-727-380-0202", total_hectares=45.5),
        Farm(farm_name="Saryarka Grain & Solanaceae", owner_name="Bolat Serikov", region="Karaganda", contact_phone="+7-721-291-0303", total_hectares=85.0),
        Farm(farm_name="Tobyl Agro Enterprise", owner_name="Dmitriy Ivanov", region="Kostanay", contact_phone="+7-714-250-0404", total_hectares=210.0),
        Farm(farm_name="Shymkent South HortiFarm", owner_name="Kairat Ospanov", region="Turkestan", contact_phone="+7-725-244-0505", total_hectares=60.0),
        Farm(farm_name="Ertis River Greenhouse Cluster", owner_name="Zhanar Temirbayeva", region="Pavlodar", contact_phone="+7-718-261-0606", total_hectares=30.0),
        Farm(farm_name="Taraz Sunshine Orchards", owner_name="Aslan Kudaibergen", region="Zhambyl", contact_phone="+7-726-231-0707", total_hectares=52.0),
        Farm(farm_name="Kyzylzhar North Field Farm", owner_name="Yerlan Smagulov", region="North Kazakhstan", contact_phone="+7-715-240-0808", total_hectares=140.0),
        Farm(farm_name="Ural Agro Innovation LLC", owner_name="Alua Baimuratova", region="West Kazakhstan", contact_phone="+7-711-228-0909", total_hectares=75.0),
        Farm(farm_name="Altai Eco Cultivation", owner_name="Murat Zhaksylykov", region="East Kazakhstan", contact_phone="+7-723-277-1010", total_hectares=38.0),
    ]
    db.add_all(farms_data)
    db.commit()

    print("[*] Seeding 10 Authorized Agricultural Users (Linked to Farms)...")
    users_data = [
        User(username="nurlan_agro", email="nurlan@baiterek-agro.kz", hashed_password=hash_password("AgroPass2026!"), full_name="Nurlan Akhmetov", role="farm_owner", farm_id=1, api_token=generate_secure_token()),
        User(username="aigerim_plant", email="aigerim@zhetysu-valley.kz", hashed_password=hash_password("Zhetysu2026!"), full_name="Aigerim Sadykova", role="farm_owner", farm_id=2, api_token=generate_secure_token()),
        User(username="bolat_agronomist", email="bolat@saryarka-grain.kz", hashed_password=hash_password("Saryarka2026!"), full_name="Bolat Serikov", role="agronomist", farm_id=3, api_token=generate_secure_token()),
        User(username="dmitriy_tobyl", email="dmitriy@tobyl-agro.kz", hashed_password=hash_password("TobylPass2026!"), full_name="Dmitriy Ivanov", role="farm_owner", farm_id=4, api_token=generate_secure_token()),
        User(username="kairat_shymkent", email="kairat@shymkent-horti.kz", hashed_password=hash_password("Shymkent2026!"), full_name="Kairat Ospanov", role="agronomist", farm_id=5, api_token=generate_secure_token()),
        User(username="zhanar_ertis", email="zhanar@ertis-greenhouse.kz", hashed_password=hash_password("Ertis2026!"), full_name="Zhanar Temirbayeva", role="agronomist", farm_id=6, api_token=generate_secure_token()),
        User(username="aslan_taraz", email="aslan@taraz-orchards.kz", hashed_password=hash_password("Taraz2026!"), full_name="Aslan Kudaibergen", role="farm_owner", farm_id=7, api_token=generate_secure_token()),
        User(username="yerlan_kyzylzhar", email="yerlan@kyzylzhar-farm.kz", hashed_password=hash_password("Kyzylzhar2026!"), full_name="Yerlan Smagulov", role="operator", farm_id=8, api_token=generate_secure_token()),
        User(username="alua_ural", email="alua@ural-agro.kz", hashed_password=hash_password("UralAgro2026!"), full_name="Alua Baimuratova", role="agronomist", farm_id=9, api_token=generate_secure_token()),
        User(username="murat_altai", email="murat@altai-eco.kz", hashed_password=hash_password("AltaiPass2026!"), full_name="Murat Zhaksylykov", role="admin", farm_id=10, api_token=generate_secure_token()),
    ]
    db.add_all(users_data)
    db.commit()

    print("[*] Seeding 10 AgriShadeNet Edge IoT Diagnostic Units...")
    devices_data = [
        Device(device_serial="AGRI-EDGE-AKM-001", farm_id=1, hardware_model="Raspberry Pi 4 / ARM Cortex-A72", firmware_version="v2.4.1", api_key_hash=hash_token("akm_key_001_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(minutes=15)),
        Device(device_serial="AGRI-EDGE-ALM-002", farm_id=2, hardware_model="Raspberry Pi 4 / ARM Cortex-A72", firmware_version="v2.4.1", api_key_hash=hash_token("alm_key_002_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(hours=2)),
        Device(device_serial="AGRI-EDGE-KAR-003", farm_id=3, hardware_model="Jetson Nano 4GB / Maxwell GPU", firmware_version="v2.4.0", api_key_hash=hash_token("kar_key_003_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(hours=5)),
        Device(device_serial="AGRI-EDGE-KOS-004", farm_id=4, hardware_model="Raspberry Pi 4 / ARM Cortex-A72", firmware_version="v2.4.1", api_key_hash=hash_token("kos_key_004_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(minutes=45)),
        Device(device_serial="AGRI-EDGE-TUR-005", farm_id=5, hardware_model="Android Rugged Tablet / Snapdragon", firmware_version="v2.3.9", api_key_hash=hash_token("tur_key_005_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(days=1)),
        Device(device_serial="AGRI-EDGE-PAV-006", farm_id=6, hardware_model="Raspberry Pi 4 / ARM Cortex-A72", firmware_version="v2.4.1", api_key_hash=hash_token("pav_key_006_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(minutes=30)),
        Device(device_serial="AGRI-EDGE-ZHA-007", farm_id=7, hardware_model="Orange Pi 5 / RK3588S", firmware_version="v2.4.1", api_key_hash=hash_token("zha_key_007_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(hours=8)),
        Device(device_serial="AGRI-EDGE-NKO-008", farm_id=8, hardware_model="Raspberry Pi 4 / ARM Cortex-A72", firmware_version="v2.4.1", api_key_hash=hash_token("nko_key_008_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(hours=12)),
        Device(device_serial="AGRI-EDGE-WKO-009", farm_id=9, hardware_model="Android Rugged Tablet / MediaTek", firmware_version="v2.4.0", api_key_hash=hash_token("wko_key_009_secret"), is_active=False, last_sync_at=datetime.now(timezone.utc) - timedelta(days=4)),
        Device(device_serial="AGRI-EDGE-EKO-010", farm_id=10, hardware_model="Raspberry Pi 4 / ARM Cortex-A72", firmware_version="v2.4.1", api_key_hash=hash_token("eko_key_010_secret"), is_active=True, last_sync_at=datetime.now(timezone.utc) - timedelta(minutes=5)),
    ]
    db.add_all(devices_data)
    db.commit()

    print("[*] Seeding 12 In-Field Crop Diagnostic Telemetry Scans...")
    scans_data = [
        DiagnosticScan(
            scan_uuid="a1b2c3d4-e5f6-7a8b-9c0d-111122223333",
            device_id=1,
            crop_type="Tomato",
            disease_label="Tomato Late Blight (Phytophthora infestans)",
            confidence_score=0.965,
            severity_level="Severe",
            latitude=51.1694,
            longitude=71.4491,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=4),
            synced_at=datetime.now(timezone.utc) - timedelta(minutes=15),
            image_sha256="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        ),
        DiagnosticScan(
            scan_uuid="b2c3d4e5-f6a7-8b9c-0d1e-222233334444",
            device_id=1,
            crop_type="Tomato",
            disease_label="Tomato Early Blight (Alternaria solani)",
            confidence_score=0.912,
            severity_level="Moderate",
            latitude=51.1712,
            longitude=71.4510,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=3),
            synced_at=datetime.now(timezone.utc) - timedelta(minutes=15),
            image_sha256="5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8",
        ),
        DiagnosticScan(
            scan_uuid="c3d4e5f6-a7b8-9c0d-1e2f-333344445555",
            device_id=2,
            crop_type="Tomato",
            disease_label="Tomato Yellow Leaf Curl Virus",
            confidence_score=0.948,
            severity_level="Critical",
            latitude=43.2389,
            longitude=76.8897,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=6),
            synced_at=datetime.now(timezone.utc) - timedelta(hours=2),
            image_sha256="4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a",
        ),
        DiagnosticScan(
            scan_uuid="d4e5f6a7-b8c9-0d1e-2f3a-444455556666",
            device_id=2,
            crop_type="Tomato",
            disease_label="Healthy Foliage",
            confidence_score=0.991,
            severity_level="Healthy",
            latitude=43.2410,
            longitude=76.8920,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=5),
            synced_at=datetime.now(timezone.utc) - timedelta(hours=2),
            image_sha256="ef2d127de37b942baad06145e54b0c619a1f22327b2ebbcfbec78f5564afe39d",
        ),
        DiagnosticScan(
            scan_uuid="e5f6a7b8-c9d0-1e2f-3a4b-555566667777",
            device_id=3,
            crop_type="Potato",
            disease_label="Potato Late Blight (Phytophthora infestans)",
            confidence_score=0.957,
            severity_level="Severe",
            latitude=49.8047,
            longitude=73.1094,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=8),
            synced_at=datetime.now(timezone.utc) - timedelta(hours=5),
            image_sha256="8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918",
        ),
        DiagnosticScan(
            scan_uuid="f6a7b8c9-d0e1-2f3a-4b5c-666677778888",
            device_id=4,
            crop_type="Potato",
            disease_label="Potato Early Blight (Alternaria grandis)",
            confidence_score=0.884,
            severity_level="Moderate",
            latitude=53.2198,
            longitude=63.6354,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=2),
            synced_at=datetime.now(timezone.utc) - timedelta(minutes=45),
            image_sha256="04f8996da763b7a969b1028ee3007569eaf3a635486ddab211d512c85b9df8fb",
        ),
        DiagnosticScan(
            scan_uuid="a7b8c9d0-e1f2-3a4b-5c6d-777788889999",
            device_id=5,
            crop_type="Pepper",
            disease_label="Pepper Bell Bacterial Spot",
            confidence_score=0.923,
            severity_level="Severe",
            latitude=42.3417,
            longitude=69.5901,
            captured_at=datetime.now(timezone.utc) - timedelta(days=1, hours=2),
            synced_at=datetime.now(timezone.utc) - timedelta(days=1),
            image_sha256="6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b",
        ),
        DiagnosticScan(
            scan_uuid="b8c9d0e1-f2a3-4b5c-6d7e-888899990000",
            device_id=6,
            crop_type="Tomato",
            disease_label="Tomato Septoria Leaf Spot",
            confidence_score=0.895,
            severity_level="Moderate",
            latitude=52.2873,
            longitude=76.9674,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=1),
            synced_at=datetime.now(timezone.utc) - timedelta(minutes=30),
            image_sha256="d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35",
        ),
        DiagnosticScan(
            scan_uuid="c9d0e1f2-a3b4-5c6d-7e8f-999900001111",
            device_id=7,
            crop_type="Tomato",
            disease_label="Tomato Bacterial Spot (Xanthomonas)",
            confidence_score=0.938,
            severity_level="Severe",
            latitude=42.8997,
            longitude=71.3783,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=10),
            synced_at=datetime.now(timezone.utc) - timedelta(hours=8),
            image_sha256="4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce",
        ),
        DiagnosticScan(
            scan_uuid="d0e1f2a3-b4c5-6d7e-8f9a-000011112222",
            device_id=8,
            crop_type="Potato",
            disease_label="Healthy Foliage",
            confidence_score=0.987,
            severity_level="Healthy",
            latitude=54.8753,
            longitude=69.1628,
            captured_at=datetime.now(timezone.utc) - timedelta(hours=15),
            synced_at=datetime.now(timezone.utc) - timedelta(hours=12),
            image_sha256="4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a",
        ),
        DiagnosticScan(
            scan_uuid="e1f2a3b4-c5d6-7e8f-9a0b-111122223334",
            device_id=10,
            crop_type="Tomato",
            disease_label="Tomato Target Spot (Corynespora casiicola)",
            confidence_score=0.876,
            severity_level="Moderate",
            latitude=49.9575,
            longitude=82.6083,
            captured_at=datetime.now(timezone.utc) - timedelta(minutes=40),
            synced_at=datetime.now(timezone.utc) - timedelta(minutes=5),
            image_sha256="ef2d127de37b942baad06145e54b0c619a1f22327b2ebbcfbec78f5564afe39d",
        ),
        DiagnosticScan(
            scan_uuid="f2a3b4c5-d6e7-8f9a-0b1c-222233334445",
            device_id=1,
            crop_type="Tomato",
            disease_label="Tomato Late Blight (Phytophthora infestans)",
            confidence_score=0.982,
            severity_level="Critical",
            latitude=51.1730,
            longitude=71.4535,
            captured_at=datetime.now(timezone.utc) - timedelta(minutes=20),
            synced_at=datetime.now(timezone.utc) - timedelta(minutes=15),
            image_sha256="a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e",
        ),
    ]
    db.add_all(scans_data)
    db.commit()

    print("[✓] Database seeding complete! Summary:")
    print(f"    - Users:      {db.query(User).count()} records (Linked to farms)")
    print(f"    - Farms:      {db.query(Farm).count()} records")
    print(f"    - Devices:    {db.query(Device).count()} records")
    print(f"    - Treatments: {db.query(AgronomicTreatment).count()} records")
    print(f"    - Scans:      {db.query(DiagnosticScan).count()} records")
    db.close()


if __name__ == "__main__":
    seed_database()
