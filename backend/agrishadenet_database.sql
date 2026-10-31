-- =============================================================================
-- AgriShadeNet Relational Database Schema & Realistic Seed Dataset
-- Course: Information and Communication Technology (ICT)
-- Institution: Astana IT University (AITU)
-- Student Author: Azat Madiyev
-- Assignment 3: Database Systems and Cybersecurity ("Give Your Product a Real Data Layer")
-- Educational Continuity: Assignment 1 & 2 -> Midterm Assessment (Project Stage 1) -> Assignment 3
-- Database Engine: SQLite / Relational SQL (Compatible with DB Browser for SQLite & sqliteonline.com)
-- =============================================================================

PRAGMA foreign_keys = ON;

-- -----------------------------------------------------------------------------
-- 1. TABLE DEFINITIONS (CLEAN DROP & RECREATE IN REVERSE DEPENDENCY ORDER)
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS scans;
DROP TABLE IF EXISTS devices;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS treatments;
DROP TABLE IF EXISTS farms;

-- Entity 1: Farms (Agricultural Enterprises)
CREATE TABLE farms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    farm_name VARCHAR(100) NOT NULL,
    owner_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    total_hectares REAL NOT NULL DEFAULT 10.0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_farms_region ON farms(region);

-- Entity 2: Users (Authorized Human Operators & Cloud Identity Accounts)
-- Enables multi-tenant cloud authentication and routes field telemetry to responsible agronomists.
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hashed_password VARCHAR(128) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'agronomist', -- farm_owner, agronomist, operator, admin
    farm_id INTEGER,
    api_token VARCHAR(64) UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE SET NULL
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_farm_id ON users(farm_id);

-- Entity 3: Devices (AgriShadeNet Edge IoT Diagnostic Nodes)
CREATE TABLE devices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    device_serial VARCHAR(50) UNIQUE NOT NULL,
    farm_id INTEGER NOT NULL,
    hardware_model VARCHAR(50) NOT NULL DEFAULT 'Raspberry Pi 4 / ARM Cortex-A72',
    firmware_version VARCHAR(20) NOT NULL DEFAULT 'v2.4.1',
    api_key_hash VARCHAR(64) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    last_sync_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE
);

CREATE INDEX idx_devices_serial ON devices(device_serial);
CREATE INDEX idx_devices_farm_id ON devices(farm_id);

-- Entity 4: Treatments (Agronomic Prescription & Dosage Protocols)
CREATE TABLE treatments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    disease_label VARCHAR(100) UNIQUE NOT NULL,
    recommended_treatment VARCHAR(150) NOT NULL,
    active_ingredient VARCHAR(100) NOT NULL,
    dosage_per_ha_liters REAL NOT NULL,
    spray_interval_days INTEGER NOT NULL,
    pre_harvest_interval_days INTEGER NOT NULL,
    cost_estimate_kzt_per_ha REAL NOT NULL
);

CREATE INDEX idx_treatments_disease ON treatments(disease_label);

-- Entity 5: Scans (In-Field Crop Pathology Diagnostics Telemetry)
CREATE TABLE scans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    scan_uuid VARCHAR(36) UNIQUE NOT NULL,
    device_id INTEGER NOT NULL,
    crop_type VARCHAR(50) NOT NULL,
    disease_label VARCHAR(100) NOT NULL,
    confidence_score REAL NOT NULL,
    severity_level VARCHAR(20) NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    captured_at TIMESTAMP NOT NULL,
    synced_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    image_sha256 VARCHAR(64) NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);

CREATE INDEX idx_scans_uuid ON scans(scan_uuid);
CREATE INDEX idx_scans_crop_disease ON scans(crop_type, disease_label);
CREATE INDEX idx_scans_severity_conf ON scans(severity_level, confidence_score);

-- -----------------------------------------------------------------------------
-- 2. REALISTIC SEED DATA (AT LEAST 10 ROWS PER TABLE)
-- -----------------------------------------------------------------------------

-- Seed Farms (10 Records)
INSERT INTO farms (id, farm_name, owner_name, region, contact_phone, total_hectares, created_at) VALUES
(1, 'Baiterek Agro Agrocomplex', 'Nurlan Akhmetov', 'Akmola', '+7-716-255-0101', 120.0, '2026-09-01 08:00:00'),
(2, 'Zhetysu Green Valley', 'Aigerim Sadykova', 'Almaty', '+7-727-380-0202', 45.5, '2026-09-02 09:15:00'),
(3, 'Saryarka Grain & Solanaceae', 'Bolat Serikov', 'Karaganda', '+7-721-291-0303', 85.0, '2026-09-05 11:30:00'),
(4, 'Tobyl Agro Enterprise', 'Dmitriy Ivanov', 'Kostanay', '+7-714-250-0404', 210.0, '2026-09-10 14:00:00'),
(5, 'Shymkent South HortiFarm', 'Kairat Ospanov', 'Turkestan', '+7-725-244-0505', 60.0, '2026-09-12 10:45:00'),
(6, 'Ertis River Greenhouse Cluster', 'Zhanar Temirbayeva', 'Pavlodar', '+7-718-261-0606', 30.0, '2026-09-15 16:20:00'),
(7, 'Taraz Sunshine Orchards', 'Aslan Kudaibergen', 'Zhambyl', '+7-726-231-0707', 52.0, '2026-09-18 08:50:00'),
(8, 'Kyzylzhar North Field Farm', 'Yerlan Smagulov', 'North Kazakhstan', '+7-715-240-0808', 140.0, '2026-09-22 13:10:00'),
(9, 'Ural Agro Innovation LLC', 'Alua Baimuratova', 'West Kazakhstan', '+7-711-228-0909', 75.0, '2026-09-25 15:30:00'),
(10, 'Altai Eco Cultivation', 'Murat Zhaksylykov', 'East Kazakhstan', '+7-723-277-1010', 38.0, '2026-09-28 12:00:00');

-- Seed Users (10 Records Linked to Farms)
INSERT INTO users (id, username, email, hashed_password, full_name, role, farm_id, api_token, is_active, created_at) VALUES
(1, 'nurlan_agro', 'nurlan@baiterek-agro.kz', '9f835438e7ff910f5451bfd7cb3c82de9cd5d2f6bb17f8b22a0a256f62b8004b', 'Nurlan Akhmetov', 'farm_owner', 1, 'tok_usr_akm_001', 1, '2026-09-01 08:30:00'),
(2, 'aigerim_plant', 'aigerim@zhetysu-valley.kz', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'Aigerim Sadykova', 'farm_owner', 2, 'tok_usr_alm_002', 1, '2026-09-02 09:30:00'),
(3, 'bolat_agronomist', 'bolat@saryarka-grain.kz', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Bolat Serikov', 'agronomist', 3, 'tok_usr_kar_003', 1, '2026-09-05 12:00:00'),
(4, 'dmitriy_tobyl', 'dmitriy@tobyl-agro.kz', '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a', 'Dmitriy Ivanov', 'farm_owner', 4, 'tok_usr_kos_004', 1, '2026-09-10 14:30:00'),
(5, 'kairat_shymkent', 'kairat@shymkent-horti.kz', 'ef2d127de37b942baad06145e54b0c619a1f22327b2ebbcfbec78f5564afe39d', 'Kairat Ospanov', 'agronomist', 5, 'tok_usr_tur_005', 1, '2026-09-12 11:15:00'),
(6, 'zhanar_ertis', 'zhanar@ertis-greenhouse.kz', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Zhanar Temirbayeva', 'agronomist', 6, 'tok_usr_pav_006', 1, '2026-09-15 16:45:00'),
(7, 'aslan_taraz', 'aslan@taraz-orchards.kz', '04f8996da763b7a969b1028ee3007569eaf3a635486ddab211d512c85b9df8fb', 'Aslan Kudaibergen', 'farm_owner', 7, 'tok_usr_zha_007', 1, '2026-09-18 09:10:00'),
(8, 'yerlan_kyzylzhar', 'yerlan@kyzylzhar-farm.kz', '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', 'Yerlan Smagulov', 'operator', 8, 'tok_usr_nko_008', 1, '2026-09-22 13:40:00'),
(9, 'alua_ural', 'alua@ural-agro.kz', 'd4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35', 'Alua Baimuratova', 'agronomist', 9, 'tok_usr_wko_009', 1, '2026-09-25 16:00:00'),
(10, 'murat_altai', 'murat@altai-eco.kz', '4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce', 'Murat Zhaksylykov', 'admin', 10, 'tok_usr_eko_010', 1, '2026-09-28 12:30:00');

-- Seed Edge Devices (10 Records with SHA-256 Key Hashes)
INSERT INTO devices (id, device_serial, farm_id, hardware_model, firmware_version, api_key_hash, is_active, last_sync_at, created_at) VALUES
(1, 'AGRI-EDGE-AKM-001', 1, 'Raspberry Pi 4 / ARM Cortex-A72', 'v2.4.1', '6878b4791a9df2e52e44f892f3d41b8d80e11893d20b8b60bb6399129e6b80fb', 1, '2026-10-21 02:45:00', '2026-09-02 10:00:00'),
(2, 'AGRI-EDGE-ALM-002', 2, 'Raspberry Pi 4 / ARM Cortex-A72', 'v2.4.1', '91a27e02cc7ff0d9fcbc333c561b3699318b87bcfe97ff76e6d11a768686e06b', 1, '2026-10-21 01:00:00', '2026-09-03 11:30:00'),
(3, 'AGRI-EDGE-KAR-003', 3, 'Jetson Nano 4GB / Maxwell GPU', 'v2.4.0', '1d26ec6b8cd6e55648ecae8f77d8531cd413b5ca5ef9a2283cb032be5a07530c', 1, '2026-10-20 22:00:00', '2026-09-06 14:00:00'),
(4, 'AGRI-EDGE-KOS-004', 4, 'Raspberry Pi 4 / ARM Cortex-A72', 'v2.4.1', '2f06745ad698b7dc3f8d975a5e3e098ffb4f0b2f694695033c415446f254e414', 1, '2026-10-21 02:15:00', '2026-09-11 09:10:00'),
(5, 'AGRI-EDGE-TUR-005', 5, 'Android Rugged Tablet / Snapdragon', 'v2.3.9', 'e12e131d86d634cf1f964be486a43876d7083072a445d4474773aa5c4c9523bb', 1, '2026-10-20 03:00:00', '2026-09-13 12:40:00'),
(6, 'AGRI-EDGE-PAV-006', 6, 'Raspberry Pi 4 / ARM Cortex-A72', 'v2.4.1', '5cb15be3c0b0f782f6460f78c8577519ff089608d13b488734e565983796d13e', 1, '2026-10-21 02:30:00', '2026-09-16 17:00:00'),
(7, 'AGRI-EDGE-ZHA-007', 7, 'Orange Pi 5 / RK3588S', 'v2.4.1', 'ea089e9be4713da2ef902e1c3a726359e13028328bf3dff9dc48d59728f32890', 1, '2026-10-20 19:00:00', '2026-09-19 10:15:00'),
(8, 'AGRI-EDGE-NKO-008', 8, 'Raspberry Pi 4 / ARM Cortex-A72', 'v2.4.1', 'd3a3bb074b1e5ec6f2946c2d96c80c2f8ec5ea72d73f1f31f9d6c7081702f74d', 1, '2026-10-20 15:00:00', '2026-09-23 14:45:00'),
(9, 'AGRI-EDGE-WKO-009', 9, 'Android Rugged Tablet / MediaTek', 'v2.4.0', 'c63ea4b8702b8bbec1d9ff85a21074a1dc52a8a8166c303f8f121e7d25164bc1', 0, '2026-10-17 11:00:00', '2026-09-26 16:30:00'),
(10, 'AGRI-EDGE-EKO-010', 10, 'Raspberry Pi 4 / ARM Cortex-A72', 'v2.4.1', '3910c53a6c981298517c2f0f78e47f9f7dcbbffca5c97ea945761fa34c1a5118', 1, '2026-10-21 02:55:00', '2026-09-29 13:20:00');

-- Seed Agronomic Treatments (10 Records)
INSERT INTO treatments (id, disease_label, recommended_treatment, active_ingredient, dosage_per_ha_liters, spray_interval_days, pre_harvest_interval_days, cost_estimate_kzt_per_ha) VALUES
(1, 'Tomato Late Blight (Phytophthora infestans)', 'Mancozeb 75% WP + Metalaxyl 8%', 'Metalaxyl-M & Mancozeb', 2.5, 7, 14, 18500.0),
(2, 'Tomato Early Blight (Alternaria solani)', 'Chlorothalonil 720 SC', 'Chlorothalonil', 2.0, 10, 7, 14200.0),
(3, 'Tomato Yellow Leaf Curl Virus', 'Imidacloprid 200 SL (Vector Control) + Reflective Mulch', 'Imidacloprid (Whitefly vector suppression)', 0.75, 14, 21, 22000.0),
(4, 'Tomato Septoria Leaf Spot', 'Copper Oxychloride 50% WP', 'Copper Oxychloride', 3.0, 7, 5, 11800.0),
(5, 'Tomato Bacterial Spot (Xanthomonas)', 'Streptomycin Sulfate + Copper Hydroxide', 'Copper Hydroxide & Streptomycin', 2.2, 7, 10, 26500.0),
(6, 'Potato Late Blight (Phytophthora infestans)', 'Cyazofamid 400 SC (Ranman)', 'Cyazofamid', 0.25, 7, 7, 21000.0),
(7, 'Potato Early Blight (Alternaria grandis)', 'Azoxystrobin 250 SC (Quadris)', 'Azoxystrobin', 0.8, 12, 14, 19400.0),
(8, 'Pepper Bell Bacterial Spot', 'Kasugamycin 2% SL (Kasumin)', 'Kasugamycin', 1.5, 8, 7, 24800.0),
(9, 'Tomato Target Spot (Corynespora casiicola)', 'Boscalid + Pyraclostrobin (Cabrio Top)', 'Boscalid & Pyraclostrobin', 1.2, 10, 10, 23500.0),
(10, 'Healthy Foliage', 'Routine Organic Micronutrient Foliar Spray (Zinc + Boron)', 'Foliar Micronutrient Complex', 1.0, 21, 0, 6500.0);

-- Seed Scans (12 Records)
INSERT INTO scans (id, scan_uuid, device_id, crop_type, disease_label, confidence_score, severity_level, latitude, longitude, captured_at, synced_at, image_sha256) VALUES
(1, 'a1b2c3d4-e5f6-7a8b-9c0d-111122223333', 1, 'Tomato', 'Tomato Late Blight (Phytophthora infestans)', 0.965, 'Severe', 51.1694, 71.4491, '2026-10-20 22:45:00', '2026-10-21 02:45:00', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
(2, 'b2c3d4e5-f6a7-8b9c-0d1e-222233334444', 1, 'Tomato', 'Tomato Early Blight (Alternaria solani)', 0.912, 'Moderate', 51.1712, 71.4510, '2026-10-20 23:45:00', '2026-10-21 02:45:00', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
(3, 'c3d4e5f6-a7b8-9c0d-1e2f-333344445555', 2, 'Tomato', 'Tomato Yellow Leaf Curl Virus', 0.948, 'Critical', 43.2389, 76.8897, '2026-10-20 20:00:00', '2026-10-21 01:00:00', '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a'),
(4, 'd4e5f6a7-b8c9-0d1e-2f3a-444455556666', 2, 'Tomato', 'Healthy Foliage', 0.991, 'Healthy', 43.2410, 76.8920, '2026-10-20 21:00:00', '2026-10-21 01:00:00', 'ef2d127de37b942baad06145e54b0c619a1f22327b2ebbcfbec78f5564afe39d'),
(5, 'e5f6a7b8-c9d0-1e2f-3a4b-555566667777', 3, 'Potato', 'Potato Late Blight (Phytophthora infestans)', 0.957, 'Severe', 49.8047, 73.1094, '2026-10-20 18:00:00', '2026-10-20 22:00:00', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'),
(6, 'f6a7b8c9-d0e1-2f3a-4b5c-666677778888', 4, 'Potato', 'Potato Early Blight (Alternaria grandis)', 0.884, 'Moderate', 53.2198, 63.6354, '2026-10-21 00:15:00', '2026-10-21 02:15:00', '04f8996da763b7a969b1028ee3007569eaf3a635486ddab211d512c85b9df8fb'),
(7, 'a7b8c9d0-e1f2-3a4b-5c6d-777788889999', 5, 'Pepper', 'Pepper Bell Bacterial Spot', 0.923, 'Severe', 42.3417, 69.5901, '2026-10-19 14:00:00', '2026-10-20 03:00:00', '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b'),
(8, 'b8c9d0e1-f2a3-4b5c-6d7e-888899990000', 6, 'Tomato', 'Tomato Septoria Leaf Spot', 0.895, 'Moderate', 52.2873, 76.9674, '2026-10-21 01:30:00', '2026-10-21 02:30:00', 'd4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35'),
(9, 'c9d0e1f2-a3b4-5c6d-7e8f-999900001111', 7, 'Tomato', 'Tomato Bacterial Spot (Xanthomonas)', 0.938, 'Severe', 42.8997, 71.3783, '2026-10-20 12:00:00', '2026-10-20 19:00:00', '4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce'),
(10, 'd0e1f2a3-b4c5-6d7e-8f9a-000011112222', 8, 'Potato', 'Healthy Foliage', 0.987, 'Healthy', 54.8753, 69.1628, '2026-10-20 08:00:00', '2026-10-20 15:00:00', '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a'),
(11, 'e1f2a3b4-c5d6-7e8f-9a0b-111122223334', 10, 'Tomato', 'Tomato Target Spot (Corynespora casiicola)', 0.876, 'Moderate', 49.9575, 82.6083, '2026-10-21 02:15:00', '2026-10-21 02:55:00', 'ef2d127de37b942baad06145e54b0c619a1f22327b2ebbcfbec78f5564afe39d'),
(12, 'f2a3b4c5-d6e7-8f9a-0b1c-222233334445', 1, 'Tomato', 'Tomato Late Blight (Phytophthora infestans)', 0.982, 'Critical', 51.1730, 71.4535, '2026-10-21 02:25:00', '2026-10-21 02:45:00', 'a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e');

-- -----------------------------------------------------------------------------
-- 3. ASSIGNMENT 3 DEMONSTRATION QUERIES
-- -----------------------------------------------------------------------------

-- Query 1: Selective Lookup (Find all severe/critical infections with >=90% confidence)
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

-- Query 2: Relational 5-Table JOIN with User Responsibility & Dosage Calculation
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

-- Query 3: Insert New Scan and Update Edge Device Last Sync
INSERT INTO scans (
    scan_uuid, device_id, crop_type, disease_label, 
    confidence_score, severity_level, latitude, longitude, 
    captured_at, synced_at, image_sha256
) VALUES (
    '9999aaaa-8888-bbbb-7777-ccccdddd1111', 1, 'Tomato', 'Tomato Late Blight (Phytophthora infestans)',
    0.978, 'Critical', 51.1745, 71.4580,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
);

UPDATE devices 
SET last_sync_at = CURRENT_TIMESTAMP 
WHERE id = 1;
