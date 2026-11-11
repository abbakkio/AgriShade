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

    print("[*] Production mode: zero mock scans seeded (scans are strictly ingested from mobile devices).")

    print("[✓] Database seeding complete! Summary:")
    print(f"    - Users:      {db.query(User).count()} records (Linked to farms)")
    print(f"    - Farms:      {db.query(Farm).count()} records")
    print(f"    - Devices:    {db.query(Device).count()} records")
    print(f"    - Treatments: {db.query(AgronomicTreatment).count()} records")
    print(f"    - Scans:      {db.query(DiagnosticScan).count()} records")
    db.close()


if __name__ == "__main__":
    seed_database()
