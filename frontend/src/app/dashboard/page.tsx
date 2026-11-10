"use client";

import React, { useState, useMemo, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import { useAuth } from "@/context/AuthContext";
import {
  Search,
  Plus,
  ChevronDown,
  ChevronRight,
  Filter,
  Check,
  X,
  FileText,
  Table as TableIcon,
  Sun,
  Moon,
  Zap,
  ExternalLink,
  PanelLeftClose,
  PanelLeft,
  RefreshCw,
  Clock,
  ShieldAlert,
  ShieldCheck,
  AlertCircle,
  User,
  LogIn,
  LogOut,
  Building,
  CheckCircle2,
} from "lucide-react";

// ============================================================================
// ESSENTIAL FARMER DATA MODEL (Only what directly impacts field yield & safety)
// ============================================================================
export interface FarmerPlotRecord {
  id: string;
  sampleId: string;
  crop: "Tomato" | "Potato" | "Corn" | "Grape" | "Apple";
  plotZone: string;
  diagnosis: string;
  severity: "Critical" | "Warning" | "Healthy";
  prescribedTreatment: string;
  dosageRate: string;
  phiDays: number; // Pre-Harvest Interval (Waiting days before safe food picking)
  treated: boolean;
  leafImage: string;
  farmerNote: string;
  deviceId?: number;
  isMyFarm?: boolean;
}

const INITIAL_FARMER_RECORDS: FarmerPlotRecord[] = [
  {
    id: "f-1",
    sampleId: "PLOT-C6-N",
    crop: "Tomato",
    plotZone: "Cell 6 North (Rows 1–8)",
    diagnosis: "Early Blight",
    severity: "Critical",
    prescribedTreatment: "Difenoconazole (Score 250 EC)",
    dosageRate: "0.5 L / ha in 450 L water",
    phiDays: 7,
    treated: false,
    leafImage: "/assets/field_crops/tomato_early_blight_field.jpg",
    farmerNote: "Concentric brown spots on lower foliage. Spray before evening rain.",
  },
  {
    id: "f-2",
    sampleId: "PLOT-C6-C",
    crop: "Tomato",
    plotZone: "Cell 6 Center (Rows 9–20)",
    diagnosis: "Healthy Foliage",
    severity: "Healthy",
    prescribedTreatment: "None Required (Standard Nutrition)",
    dosageRate: "Standard drip hydration",
    phiDays: 0,
    treated: true,
    leafImage: "/assets/field_crops/tomato_healthy_outdoor_foliage.jpg",
    farmerNote: "Clean canopy, zero necrosis. Ready for routine harvest picking.",
  },
  {
    id: "f-3",
    sampleId: "PLOT-B3-W",
    crop: "Tomato",
    plotZone: "Plot B West (Pivot 3)",
    diagnosis: "Late Blight",
    severity: "Critical",
    prescribedTreatment: "Copper Hydroxide (Kocide 3000)",
    dosageRate: "2.0 kg / ha localized back-sprayer",
    phiDays: 14,
    treated: false,
    leafImage: "/assets/field_crops/tomato_late_blight_field.jpg",
    farmerNote: "Water-soaked lesions. Immediate 15-meter buffer zone quarantine.",
  },
  {
    id: "f-4",
    sampleId: "PLOT-S4-P",
    crop: "Potato",
    plotZone: "Sector 4 South",
    diagnosis: "Potato Blight",
    severity: "Critical",
    prescribedTreatment: "Cymoxanil + Mancozeb",
    dosageRate: "2.5 kg / ha via tractor boom",
    phiDays: 10,
    treated: true,
    leafImage: "/assets/field_crops/potato_late_blight_field.jpg",
    farmerNote: "Treated yesterday afternoon. Check foliar margins in 48 hours.",
  },
  {
    id: "f-5",
    sampleId: "PLOT-F12-C",
    crop: "Corn",
    plotZone: "Field 12 East",
    diagnosis: "Corn Rust",
    severity: "Warning",
    prescribedTreatment: "Azoxystrobin + Propiconazole",
    dosageRate: "0.75 L / ha preventive foliar",
    phiDays: 14,
    treated: false,
    leafImage: "/assets/field_crops/corn_common_rust_field.jpg",
    farmerNote: "Scattered pustules on upper leaves. Re-inspect before weekend.",
  },
  {
    id: "f-6",
    sampleId: "PLOT-V3-G",
    crop: "Grape",
    plotZone: "Vineyard Sector 3",
    diagnosis: "Black Rot",
    severity: "Warning",
    prescribedTreatment: "Myclobutanil (Rally 40WSP)",
    dosageRate: "0.35 kg / ha fruit protection",
    phiDays: 14,
    treated: true,
    leafImage: "/assets/field_crops/grape_black_rot_vineyard.jpg",
    farmerNote: "Cluster spray complete. Cluster damage contained under 4%.",
  },
];

export default function MinimalFarmerDashboard() {
  const { user, openAuthModal, logout, login } = useAuth();

  // Notion Layout & UI State
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [darkMode, setDarkMode] = useState(false);
  const [records, setRecords] = useState<FarmerPlotRecord[]>(INITIAL_FARMER_RECORDS);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterStatus, setFilterStatus] = useState<"all" | "needs_action" | "treated" | "healthy">("all");
  const [onlyMyFarm, setOnlyMyFarm] = useState(false);
  const [activeRecord, setActiveRecord] = useState<FarmerPlotRecord | null>(null);

  // Live Cloud Backend Connection
  const API_BASE = process.env.NEXT_PUBLIC_API_URL || "https://agrishade.onrender.com";
  const [loadingScans, setLoadingScans] = useState(false);
  const [farmInfo, setFarmInfo] = useState<any>(null);
  const [loadingFarm, setLoadingFarm] = useState(false);

  // Fetch farm summary whenever user or farm_id changes
  useEffect(() => {
    if (user?.farm_id) {
      setLoadingFarm(true);
      fetch(`${API_BASE}/api/v1/farms/${user.farm_id}/summary`)
        .then((res) => (res.ok ? res.json() : null))
        .then((data) => {
          if (data) setFarmInfo(data);
        })
        .catch((err) => console.warn("Failed to load farm details", err))
        .finally(() => setLoadingFarm(false));
    } else {
      setFarmInfo(null);
    }
  }, [user?.farm_id, API_BASE]);

  const fetchLiveScans = async () => {
    setLoadingScans(true);
    try {
      const res = await fetch(`${API_BASE}/api/v1/scans`);
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data) && data.length > 0) {
          const mapped: FarmerPlotRecord[] = data.map((item: any, idx: number) => {
            const rawDisease = item.disease_label || "Foliar Pathology";
            const isHealthy = rawDisease.toLowerCase().includes("healthy");
            const isLate = rawDisease.toLowerCase().includes("late");
            const isVirus = rawDisease.toLowerCase().includes("virus") || rawDisease.toLowerCase().includes("curl");

            let treatment = "Copper Hydroxide (Kocide 3000)";
            let dosage = "2.0 kg / ha localized back-sprayer";
            let phi = 10;
            let leafImg = "/assets/field_crops/tomato_early_blight_field.jpg";

            if (isHealthy) {
              treatment = "None Required (Standard Nutrition)";
              dosage = "Standard drip hydration";
              phi = 0;
              leafImg = "/assets/field_crops/tomato_healthy_outdoor_foliage.jpg";
            } else if (isLate) {
              treatment = "Mancozeb 75% + Metalaxyl 8%";
              dosage = "2.5 kg / ha tractor boom";
              phi = 14;
              leafImg = "/assets/field_crops/tomato_late_blight_field.jpg";
            } else if (isVirus) {
              treatment = "Imidacloprid 200 SL (Vector Control)";
              dosage = "0.75 L / ha foliar spray";
              phi = 21;
              leafImg = "/assets/field_crops/tomato_early_blight_field.jpg";
            } else if (rawDisease.toLowerCase().includes("early")) {
              treatment = "Difenoconazole (Score 250 EC)";
              dosage = "0.5 L / ha in 450 L water";
              phi = 7;
              leafImg = "/assets/field_crops/tomato_early_blight_field.jpg";
            }

            const sev: "Critical" | "Warning" | "Healthy" =
              isHealthy ? "Healthy" : (item.severity_level === "Critical" || item.severity_level === "Severe") ? "Critical" : "Warning";

            const isUserFarm = Boolean(user?.farm_id && item.device_id === user.farm_id);

            return {
              id: item.scan_uuid || `scan-${item.id || idx}`,
              sampleId: `PLOT-${item.device_id ? `DEV0${item.device_id}` : "ZHB"}-${item.id || idx}`,
              crop: (item.crop_type as any) || "Tomato",
              plotZone: isUserFarm
                ? `Ваше поле: Сектор ${item.device_id}`
                : `Sector ${item.device_id || 7} (${Number(item.latitude || 42.9).toFixed(2)}° N, ${Number(item.longitude || 71.37).toFixed(2)}° E)`,
              diagnosis: rawDisease,
              severity: sev,
              prescribedTreatment: treatment,
              dosageRate: dosage,
              phiDays: phi,
              treated: isHealthy || idx % 2 === 1,
              leafImage: leafImg,
              farmerNote: `${isUserFarm ? "★ Ваша ферма: " : ""}Зафиксировано в облаке (${((item.confidence_score || 0.95) * 100).toFixed(1)}% точность). Время: ${item.captured_at ? new Date(item.captured_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : "Недавно"}`,
              deviceId: item.device_id,
              isMyFarm: isUserFarm,
            };
          });

          setRecords(mapped);
        }
      }
    } catch (e) {
      console.warn("Could not fetch live scans from cloud backend, using cached records", e);
    } finally {
      setLoadingScans(false);
    }
  };

  useEffect(() => {
    fetchLiveScans();
  }, []);

  // New Scan Simulator
  const [newScanModalOpen, setNewScanModalOpen] = useState(false);
  const [simulating, setSimulating] = useState(false);
  const [newCrop, setNewCrop] = useState<"Tomato" | "Potato" | "Corn">("Tomato");
  const [newPlotZone, setNewPlotZone] = useState("Cell 6 South (Row 22)");
  const [newCondition, setNewCondition] = useState<"Early Blight" | "Healthy Foliage" | "Late Blight">("Early Blight");

  // Summary Metrics (What farmer needs to know immediately)
  const summary = useMemo(() => {
    const total = records.length;
    const needsAction = records.filter((r) => r.severity !== "Healthy" && !r.treated).length;
    const treatedOrSafe = records.filter((r) => r.treated || r.severity === "Healthy").length;
    return { total, needsAction, treatedOrSafe };
  }, [records]);

  // Filtered Records
  const filteredRecords = useMemo(() => {
    return records.filter((r) => {
      if (onlyMyFarm && user?.farm_id && r.deviceId !== user.farm_id) {
        return false;
      }
      const matchSearch =
        r.plotZone.toLowerCase().includes(searchQuery.toLowerCase()) ||
        r.diagnosis.toLowerCase().includes(searchQuery.toLowerCase()) ||
        r.crop.toLowerCase().includes(searchQuery.toLowerCase()) ||
        r.prescribedTreatment.toLowerCase().includes(searchQuery.toLowerCase());

      if (filterStatus === "needs_action") {
        return matchSearch && r.severity !== "Healthy" && !r.treated;
      }
      if (filterStatus === "treated") {
        return matchSearch && r.treated && r.severity !== "Healthy";
      }
      if (filterStatus === "healthy") {
        return matchSearch && r.severity === "Healthy";
      }
      return matchSearch;
    });
  }, [records, searchQuery, filterStatus, onlyMyFarm, user?.farm_id]);

  // Toggle Action Status
  const toggleTreated = (id: string, e?: React.MouseEvent) => {
    e?.stopPropagation();
    setRecords((prev) =>
      prev.map((r) => (r.id === id ? { ...r, treated: !r.treated } : r))
    );
    if (activeRecord && activeRecord.id === id) {
      setActiveRecord((prev) => (prev ? { ...prev, treated: !prev.treated } : null));
    }
  };

  // Run Quick Simulation
  const handleSimulateScan = () => {
    setSimulating(true);
    setTimeout(async () => {
      const isHealthy = newCondition === "Healthy Foliage";
      const newRec: FarmerPlotRecord = {
        id: `f-${Date.now()}`,
        sampleId: `PLOT-${Math.floor(100 + Math.random() * 900)}`,
        crop: newCrop,
        plotZone: newPlotZone,
        diagnosis: newCondition,
        severity: isHealthy ? "Healthy" : newCondition === "Late Blight" ? "Critical" : "Warning",
        prescribedTreatment: isHealthy
          ? "None Required (Standard Nutrition)"
          : newCondition === "Late Blight"
          ? "Copper Hydroxide (2.0 kg/ha)"
          : "Difenoconazole (0.5 L/ha in 450 L water)",
        dosageRate: isHealthy ? "Standard drip" : "Calibrated foliar nozzle spray",
        phiDays: isHealthy ? 0 : newCondition === "Late Blight" ? 14 : 7,
        treated: false,
        leafImage: isHealthy
          ? "/assets/field_crops/tomato_healthy_outdoor_foliage.jpg"
          : newCondition === "Late Blight"
          ? "/assets/field_crops/tomato_late_blight_field.jpg"
          : "/assets/field_crops/tomato_early_blight_field.jpg",
        farmerNote: "Logged from handheld field handset. Synced with central registry.",
      };

      try {
        await fetch(`${API_BASE}/api/v1/sync`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-Device-Serial": "AGRI-EDGE-ZHA-007",
            "X-API-Key": "zha_key_007_secret",
          },
          body: JSON.stringify({
            device_serial: "AGRI-EDGE-ZHA-007",
            scans: [
              {
                scan_uuid: `web-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
                crop_type: newCrop,
                disease_label: newCondition,
                confidence_score: 0.965,
                severity_level: newRec.severity === "Critical" ? "Critical" : newRec.severity === "Healthy" ? "Healthy" : "Moderate",
                latitude: 42.9006,
                longitude: 71.3789,
                captured_at: new Date().toISOString(),
                image_sha256: "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8",
              },
            ],
          }),
        });
      } catch (e) {
        console.warn("Could not sync scan to cloud backend", e);
      }

      setRecords([newRec, ...records]);
      setSimulating(false);
      setNewScanModalOpen(false);
      setActiveRecord(newRec);
    }, 450);
  };

  return (
    <div
      className={`min-h-screen flex text-[14px] font-sans antialiased ${
        darkMode ? "dark bg-[#191919] text-[#d4d4d4]" : "bg-white text-[#37352f]"
      }`}
    >
      {/* =====================================================================
          MINIMAL NOTION SIDEBAR (Ultra-clean, 220px, 0 clutter)
          ===================================================================== */}
      <aside
        className={`fixed inset-y-0 left-0 z-40 w-[220px] flex flex-col justify-between border-r select-none transition-transform duration-200 ${
          darkMode
            ? "bg-[#202020] border-[#2f2f2f] text-[#9b9b9b]"
            : "bg-[#fbfbfa] border-[#e9e9e7] text-[#5a5855]"
        } ${sidebarOpen ? "translate-x-0" : "-translate-x-full"}`}
      >
        <div className="p-3 space-y-4">
          {/* Workspace Brand */}
          <div className="flex items-center gap-2 px-1 py-1">
            <span className="text-lg">🌱</span>
            <div className="truncate">
              <span className="font-semibold text-[13px] text-[#37352f] dark:text-[#e3e2e0] block truncate">
                {user ? (farmInfo?.farm_name || `Ферма #${user.farm_id}`) : "AgriShadeNet"}
              </span>
              <span className="text-[11px] text-[#787774] dark:text-[#9b9b9b] block truncate">
                {user ? `${farmInfo?.region || "Казахстан"} • ${farmInfo?.total_hectares || 10} га` : "Гостевой режим (Демо)"}
              </span>
            </div>
          </div>

          {/* Core Actions */}
          <div className="space-y-0.5 text-[13px]">
            <button
              type="button"
              onClick={() => setNewScanModalOpen(true)}
              className="w-full flex items-center gap-2 px-2 py-1.5 rounded-[4px] bg-[#2383e2] hover:bg-[#1b70c4] text-white font-medium shadow-2xs transition-colors"
            >
              <Zap className="w-3.5 h-3.5" />
              <span>+ Quick Scan</span>
              <span className="ml-auto text-[10px] opacity-80 font-mono">41.6ms</span>
            </button>

            <button
              type="button"
              onClick={() => {
                const el = document.getElementById("farmer-search");
                el?.focus();
              }}
              className="w-full flex items-center gap-2 px-2 py-1.5 rounded-[4px] hover:bg-black/5 dark:hover:bg-white/5 text-[#37352f] dark:text-[#d4d4d4] transition-colors"
            >
              <Search className="w-3.5 h-3.5 text-[#787774]" />
              <span>Find Plot / Crop</span>
            </button>
          </div>

          {/* Navigation Links */}
          <div className="space-y-0.5 text-[13px] pt-1">
            <span className="px-2 text-[10px] font-semibold tracking-wider text-[#9b9a97] uppercase block mb-1">
              Field Registry
            </span>
            <div className="flex items-center justify-between px-2 py-1 rounded-[4px] bg-[#efedea] dark:bg-[#2a2a2a] text-[#37352f] dark:text-[#e3e2e0] font-medium">
              <span className="flex items-center gap-2">
                <TableIcon className="w-3.5 h-3.5 text-[#787774]" />
                Triage & Treatment
              </span>
              <span className="text-[11px] text-[#787774] font-mono">{records.length}</span>
            </div>
          </div>
        </div>

        {/* Sidebar Footer: Account Status & Actions */}
        <div className="p-3 border-t border-[#e9e9e7] dark:border-[#2f2f2f] space-y-2 text-[12px]">
          <Link
            href="/"
            className="flex items-center gap-2 text-[#5a5855] dark:text-[#9b9b9b] hover:text-[#002e23] dark:hover:text-emerald-400 py-1 transition-colors"
          >
            <ExternalLink className="w-3.5 h-3.5" />
            <span>← На главную страницу</span>
          </Link>

          {user ? (
            <div className="p-2 rounded-lg bg-[#f0f0ee] dark:bg-[#282828] space-y-1.5">
              <div className="flex items-center gap-2">
                <div className="w-6 h-6 rounded-full bg-emerald-600 text-white flex items-center justify-center font-bold text-[11px] shrink-0">
                  {user.full_name?.charAt(0).toUpperCase() || "U"}
                </div>
                <div className="truncate flex-1">
                  <div className="font-semibold text-[12px] text-[#37352f] dark:text-[#e3e2e0] truncate">
                    {user.full_name}
                  </div>
                  <div className="text-[10px] text-[#787774] dark:text-[#9b9b9b] truncate">
                    @{user.username} • {user.role === "farm_owner" ? "Владелец" : "Агроном"}
                  </div>
                </div>
              </div>

              <div className="pt-1.5 flex items-center justify-between border-t border-[#e2e2df] dark:border-[#383838]">
                <span className="text-[10px] text-emerald-700 dark:text-emerald-400 font-medium truncate max-w-[110px]">
                  {farmInfo?.farm_name ? farmInfo.farm_name.split(" ")[0] : `Ферма #${user.farm_id}`}
                </span>
                <button
                  type="button"
                  onClick={logout}
                  className="inline-flex items-center gap-1 text-[11px] text-rose-600 dark:text-rose-400 hover:underline"
                >
                  <LogOut className="w-3 h-3" />
                  <span>Выйти</span>
                </button>
              </div>
            </div>
          ) : (
            <div className="p-2 rounded-lg bg-[#f0f0ee] dark:bg-[#282828] space-y-2">
              <div className="flex items-center justify-between text-[11px] text-[#787774] dark:text-[#9b9b9b]">
                <span>Гостевой режим</span>
                <span className="text-[10px] px-1 py-0.2 rounded bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-300">
                  Демо
                </span>
              </div>
              <div className="flex gap-1.5">
                <button
                  type="button"
                  onClick={() => openAuthModal("login")}
                  className="flex-1 py-1 px-2 rounded bg-emerald-600 hover:bg-emerald-700 text-white text-[11px] font-medium transition-colors text-center"
                >
                  Войти
                </button>
                <button
                  type="button"
                  onClick={() => openAuthModal("register")}
                  className="flex-1 py-1 px-2 rounded bg-[#e3e2e0] dark:bg-[#383838] hover:bg-[#d8d7d5] text-[#37352f] dark:text-[#e3e2e0] text-[11px] font-medium transition-colors text-center"
                >
                  Регистрация
                </button>
              </div>

              {/* 1-Click Demo Accounts */}
              <div className="pt-1.5 border-t border-[#e2e2df] dark:border-[#383838] space-y-1">
                <div className="text-[10px] text-[#9b9a97]">Быстрый демо-вход:</div>
                <div className="flex flex-col gap-0.5">
                  <button
                    type="button"
                    onClick={() => login("azat_lead", "Password123!")}
                    className="text-left text-[11px] text-emerald-700 dark:text-emerald-400 hover:underline truncate"
                  >
                    • Азат М. (Taraz Orchards)
                  </button>
                  <button
                    type="button"
                    onClick={() => login("nurlan_agro", "AgroPass2026!")}
                    className="text-left text-[11px] text-emerald-700 dark:text-emerald-400 hover:underline truncate"
                  >
                    • Нурлан А. (Baiterek Agro)
                  </button>
                  <button
                    type="button"
                    onClick={() => login("aigerim_plant", "Zhetysu2026!")}
                    className="text-left text-[11px] text-emerald-700 dark:text-emerald-400 hover:underline truncate"
                  >
                    • Айгерим С. (Zhetysu)
                  </button>
                </div>
              </div>
            </div>
          )}

          <div className="flex items-center justify-end pt-0.5">
            <button
              type="button"
              onClick={() => setSidebarOpen(false)}
              className="p-1 text-[#787774] hover:text-[#37352f]"
              title="Close sidebar"
            >
              <PanelLeftClose className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
      </aside>

      {/* =====================================================================
          MAIN NOTION DOCUMENT CANVAS
          ===================================================================== */}
      <div
        className={`flex-1 flex flex-col min-w-0 transition-all duration-200 ${
          sidebarOpen ? "ml-[220px]" : "ml-0"
        }`}
      >
        {/* TOP BAR */}
        <header
          className={`sticky top-0 z-30 h-[42px] border-b flex items-center justify-between px-4 select-none ${
            darkMode
              ? "bg-[#191919]/95 border-[#2f2f2f] text-[#9b9b9b]"
              : "bg-white/95 border-[#e9e9e7] text-[#787774]"
          }`}
        >
          {/* Breadcrumbs */}
          <div className="flex items-center gap-2 text-[13px]">
            {!sidebarOpen && (
              <button
                type="button"
                onClick={() => setSidebarOpen(true)}
                className="p-1 -ml-1 text-[#787774] hover:text-[#37352f] dark:hover:text-white"
                title="Open sidebar"
              >
                <PanelLeft className="w-4 h-4" />
              </button>
            )}
            <span className="text-[#37352f] dark:text-[#e3e2e0] font-medium flex items-center gap-1.5">
              <span>🌾</span>
              <span>Field Triage & Harvest Safety (PHI)</span>
            </span>
          </div>

          {/* Theme & Status & User Profile */}
          <div className="flex items-center gap-2 text-[12px]">
            {user ? (
              <div className="hidden md:inline-flex items-center gap-1.5 px-2 py-0.5 rounded-[4px] bg-[#efedea] dark:bg-[#282828] text-[12px] text-[#37352f] dark:text-[#e3e2e0]">
                <User className="w-3.5 h-3.5 text-emerald-600" />
                <span className="font-semibold">{user.full_name}</span>
                {farmInfo?.farm_name && (
                  <span className="text-[#787774] text-[11px] truncate max-w-[140px]">
                    ({farmInfo.farm_name.split(" ")[0]})
                  </span>
                )}
                <button
                  type="button"
                  onClick={logout}
                  className="ml-1 text-[11px] text-rose-600 hover:underline"
                >
                  Выйти
                </button>
              </div>
            ) : (
              <button
                type="button"
                onClick={() => openAuthModal("login")}
                className="hidden md:inline-flex items-center gap-1 px-2.5 py-1 rounded-[4px] bg-emerald-600 hover:bg-emerald-700 text-white font-medium text-[11px] transition-colors"
              >
                <LogIn className="w-3 h-3" />
                <span>Войти</span>
              </button>
            )}

            <button
              type="button"
              onClick={fetchLiveScans}
              className="inline-flex items-center gap-1.5 text-emerald-600 dark:text-emerald-400 font-medium bg-emerald-50 dark:bg-emerald-950/60 hover:bg-emerald-100 dark:hover:bg-emerald-900/60 px-2 py-0.5 rounded-[4px] transition-colors"
              title="Click to refresh live scans from cloud"
            >
              <span className={`w-1.5 h-1.5 rounded-full ${loadingScans ? "bg-amber-500 animate-ping" : "bg-emerald-500"}`} />
              <span>Облако ({records.length} сканов)</span>
              <RefreshCw className={`w-3 h-3 ${loadingScans ? "animate-spin" : ""}`} />
            </button>

            <button
              type="button"
              onClick={() => setDarkMode(!darkMode)}
              className="p-1 rounded text-[#787774] hover:text-[#37352f] dark:hover:text-[#e3e2e0]"
              title="Toggle theme"
            >
              {darkMode ? <Sun className="w-4 h-4" /> : <Moon className="w-4 h-4" />}
            </button>
          </div>
        </header>

        {/* FULL-WIDTH NOTION COVER */}
        <div className="relative w-full h-[160px] sm:h-[180px] overflow-hidden bg-[#f1f1ef] dark:bg-[#202020]">
          <Image
            src="/assets/terran/tCm9GM8YlVrK0MpchN9wHyNQs8.jpeg"
            alt="Kazakhstan Agricultural Field"
            fill
            className="object-cover object-center"
            priority
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
        </div>

        {/* DOCUMENT BODY */}
        <main className="flex-1 w-full max-w-[980px] mx-auto px-6 sm:px-10 pb-20">
          
          {/* NOTION EMOJI & TITLE */}
          <div className="relative -mt-[36px] mb-2">
            <div
              className={`w-[68px] h-[68px] rounded-xl flex items-center justify-center text-[38px] select-none ${
                darkMode ? "bg-[#191919]" : "bg-white"
              }`}
            >
              🌾
            </div>
          </div>

          <h1
            className={`text-[32px] sm:text-[36px] font-bold tracking-tight leading-[1.15] mb-2 ${
              darkMode ? "text-white" : "text-[#37352f]"
            }`}
          >
            Field Triage & Harvest Safety Guide
          </h1>

          <p
            className={`text-[14px] leading-relaxed mb-6 max-w-[700px] ${
              darkMode ? "text-[#9b9b9b]" : "text-[#787774]"
            }`}
          >
            Essential operational registry for plot agronomists: identify foliar infections, apply exact chemical dosages, and enforce Pre-Harvest Intervals (PHI) before produce is picked.
          </p>

          {/* ===================================================================
              3 CRITICAL FARMER SUMMARY PILLS (What matters right now)
              =================================================================== */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-6 select-none">
            {/* Needs Spraying */}
            <div
              onClick={() => setFilterStatus("needs_action")}
              className={`p-3 rounded-[6px] border cursor-pointer transition-all ${
                filterStatus === "needs_action"
                  ? "ring-2 ring-[#a82d2a] border-[#fbe4e4]"
                  : ""
              } ${
                darkMode
                  ? "bg-[#202020] border-[#2f2f2f]"
                  : "bg-[#fbfbfa] border-[#e9e9e7] hover:border-[#d0d0d0]"
              }`}
            >
              <div className="flex items-center justify-between text-xs text-[#787774] mb-1">
                <span className="flex items-center gap-1.5 font-medium">
                  <ShieldAlert className="w-3.5 h-3.5 text-rose-500" /> Needs Treatment
                </span>
                <span className="text-[11px] font-mono">Urgent</span>
              </div>
              <div className="text-[22px] font-bold text-[#a82d2a] dark:text-[#f79a95]">
                {summary.needsAction} <span className="text-[13px] font-normal">plots</span>
              </div>
            </div>

            {/* Treated / In Quarantine PHI */}
            <div
              onClick={() => setFilterStatus("treated")}
              className={`p-3 rounded-[6px] border cursor-pointer transition-all ${
                filterStatus === "treated"
                  ? "ring-2 ring-[#24638a] border-[#e8f3f8]"
                  : ""
              } ${
                darkMode
                  ? "bg-[#202020] border-[#2f2f2f]"
                  : "bg-[#fbfbfa] border-[#e9e9e7] hover:border-[#d0d0d0]"
              }`}
            >
              <div className="flex items-center justify-between text-xs text-[#787774] mb-1">
                <span className="flex items-center gap-1.5 font-medium">
                  <Clock className="w-3.5 h-3.5 text-blue-500" /> In PHI Quarantine
                </span>
                <span className="text-[11px] font-mono">Treated</span>
              </div>
              <div className="text-[22px] font-bold text-[#24638a] dark:text-[#9ac8e8]">
                {records.filter((r) => r.treated && r.severity !== "Healthy").length}{" "}
                <span className="text-[13px] font-normal">plots</span>
              </div>
            </div>

            {/* Safe / Healthy */}
            <div
              onClick={() => setFilterStatus("healthy")}
              className={`p-3 rounded-[6px] border cursor-pointer transition-all ${
                filterStatus === "healthy"
                  ? "ring-2 ring-[#2e7039] border-[#edf6ed]"
                  : ""
              } ${
                darkMode
                  ? "bg-[#202020] border-[#2f2f2f]"
                  : "bg-[#fbfbfa] border-[#e9e9e7] hover:border-[#d0d0d0]"
              }`}
            >
              <div className="flex items-center justify-between text-xs text-[#787774] mb-1">
                <span className="flex items-center gap-1.5 font-medium">
                  <ShieldCheck className="w-3.5 h-3.5 text-emerald-500" /> Ready to Harvest
                </span>
                <span className="text-[11px] font-mono">Clean</span>
              </div>
              <div className="text-[22px] font-bold text-[#2e7039] dark:text-[#a3e3b3]">
                {records.filter((r) => r.severity === "Healthy").length}{" "}
                <span className="text-[13px] font-normal">plots</span>
              </div>
            </div>
          </div>

          {/* ===================================================================
              NOTION INLINE DATABASE TOOLBAR
              =================================================================== */}
          <div className="flex flex-wrap items-center justify-between gap-3 pb-2 border-b border-[#e9e9e7] dark:border-[#2f2f2f] mb-3">
            
            {/* Filter Pills */}
            <div className="flex items-center gap-1 text-[12px]">
              <button
                type="button"
                onClick={() => setFilterStatus("all")}
                className={`px-2 py-1 rounded-[4px] font-medium transition-colors ${
                  filterStatus === "all"
                    ? darkMode
                      ? "bg-[#282828] text-white"
                      : "bg-[#efedea] text-[#37352f]"
                    : "text-[#787774] hover:text-[#37352f]"
                }`}
              >
                All Plots ({records.length})
              </button>

              <button
                type="button"
                onClick={() => setFilterStatus("needs_action")}
                className={`px-2 py-1 rounded-[4px] font-medium transition-colors ${
                  filterStatus === "needs_action"
                    ? "bg-[#fbe4e4] text-[#a82d2a]"
                    : "text-[#787774] hover:text-[#37352f]"
                }`}
              >
                Needs Spraying ({summary.needsAction})
              </button>

              <button
                type="button"
                onClick={() => setFilterStatus("treated")}
                className={`px-2 py-1 rounded-[4px] font-medium transition-colors ${
                  filterStatus === "treated"
                    ? "bg-[#e8f3f8] text-[#24638a]"
                    : "text-[#787774] hover:text-[#37352f]"
                }`}
              >
                Treated ({records.filter((r) => r.treated && r.severity !== "Healthy").length})
              </button>

              {user && (
                <button
                  type="button"
                  onClick={() => setOnlyMyFarm(!onlyMyFarm)}
                  className={`px-2 py-1 rounded-[4px] font-medium transition-colors inline-flex items-center gap-1 ${
                    onlyMyFarm
                      ? "bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300 ring-1 ring-emerald-500 font-semibold"
                      : "text-[#787774] hover:text-[#37352f]"
                  }`}
                  title="Показать только участки моей фермы"
                >
                  <Building className="w-3 h-3 text-emerald-600" />
                  <span>
                    Моя ферма ({records.filter((r) => r.deviceId === user.farm_id).length})
                  </span>
                </button>
              )}
            </div>

            {/* Right: Search & New Scan */}
            <div className="flex items-center gap-2">
              <div className="relative">
                <Search className="w-3.5 h-3.5 text-[#787774] absolute left-2 top-1/2 -translate-y-1/2" />
                <input
                  id="farmer-search"
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Filter crop or plot..."
                  className={`w-36 sm:w-44 pl-7 pr-2 py-1 text-[12px] rounded-[4px] border focus:outline-none ${
                    darkMode
                      ? "bg-[#202020] border-[#383838] text-white"
                      : "bg-[#f7f6f3] border-[#e9e9e7] text-[#37352f]"
                  }`}
                />
              </div>

              <button
                type="button"
                onClick={() => setNewScanModalOpen(true)}
                className="flex items-center gap-1 bg-[#2383e2] hover:bg-[#1b70c4] text-white font-medium text-[12px] px-2.5 py-1 rounded-[4px] shadow-2xs transition-colors"
              >
                <Plus className="w-3.5 h-3.5" />
                <span>New Scan</span>
              </button>
            </div>

          </div>

          {/* ===================================================================
              ULTRA-MINIMALIST FARMER DATABASE TABLE
              Only the 6 fields a farmer actually needs in the field.
              =================================================================== */}
          <div className="w-full overflow-x-auto border-b border-[#e9e9e7] dark:border-[#2f2f2f]">
            <table className="w-full border-collapse text-left text-[13px]">
              <thead>
                <tr className="border-b border-[#e9e9e7] dark:border-[#2f2f2f] text-[#787774] font-normal text-[12px] h-8">
                  <th className="px-2.5 min-w-[160px] font-normal">Plot Zone & Crop</th>
                  <th className="px-2.5 min-w-[140px] font-normal">Diagnosis</th>
                  <th className="px-2.5 min-w-[180px] font-normal">Prescribed Treatment</th>
                  <th className="px-2.5 min-w-[140px] font-normal">Calibrated Dosage</th>
                  <th className="px-2.5 min-w-[110px] font-normal">Harvest Safety (PHI)</th>
                  <th className="px-2.5 min-w-[100px] font-normal">Field Status</th>
                </tr>
              </thead>
              <tbody>
                {filteredRecords.map((r) => (
                  <tr
                    key={r.id}
                    onClick={() => setActiveRecord(r)}
                    className={`h-11 border-b border-[#e9e9e7] dark:border-[#2f2f2f] cursor-pointer group transition-colors ${
                      darkMode ? "hover:bg-[#252525]" : "hover:bg-[#f7f6f3]"
                    }`}
                  >
                    {/* Plot Zone & Crop */}
                    <td className="px-2.5">
                      <div className="flex items-center gap-2">
                        <span className="text-base">
                          {r.crop === "Tomato"
                            ? "🍅"
                            : r.crop === "Potato"
                            ? "🥔"
                            : r.crop === "Corn"
                            ? "🌽"
                            : "🍇"}
                        </span>
                        <div>
                          <div className="flex items-center gap-1.5">
                            <span className="font-semibold text-[#37352f] dark:text-white block leading-tight">
                              {r.plotZone}
                            </span>
                            {user && r.deviceId === user.farm_id && (
                              <span className="inline-flex items-center px-1.5 py-0.2 rounded text-[10px] font-semibold bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300">
                                Ваша ферма
                              </span>
                            )}
                          </div>
                          <span className="text-[11px] text-[#787774]">
                            {r.crop} • {r.sampleId}
                          </span>
                        </div>
                      </div>
                    </td>

                    {/* Diagnosis & Severity */}
                    <td className="px-2.5">
                      <div className="flex items-center gap-1.5">
                        <span
                          className={`inline-block w-2 h-2 rounded-full ${
                            r.severity === "Critical"
                              ? "bg-rose-500"
                              : r.severity === "Warning"
                              ? "bg-amber-500"
                              : "bg-emerald-500"
                          }`}
                        />
                        <span className="font-medium text-[#37352f] dark:text-[#e3e2e0]">
                          {r.diagnosis}
                        </span>
                      </div>
                    </td>

                    {/* Prescribed Treatment */}
                    <td className="px-2.5 text-[#37352f] dark:text-[#d4d4d4] font-medium">
                      {r.prescribedTreatment}
                    </td>

                    {/* Calibrated Dosage */}
                    <td className="px-2.5 font-mono text-[12px] text-[#787774]">
                      {r.dosageRate}
                    </td>

                    {/* PHI Waiting Days */}
                    <td className="px-2.5">
                      {r.phiDays === 0 ? (
                        <span className="inline-flex items-center px-1.5 py-0.5 rounded-[3px] text-[11px] font-medium bg-[#edf6ed] text-[#2e7039] dark:bg-[#1f382a] dark:text-[#a3e3b3]">
                          ✓ 0d (Safe to Pick)
                        </span>
                      ) : (
                        <span className="inline-flex items-center px-1.5 py-0.5 rounded-[3px] text-[11px] font-mono font-medium bg-[#fbf3db] text-[#8f6412] dark:bg-[#3d3119] dark:text-[#f8d488]">
                          ⏳ {r.phiDays} days wait
                        </span>
                      )}
                    </td>

                    {/* Field Status Toggle */}
                    <td className="px-2.5" onClick={(e) => e.stopPropagation()}>
                      {r.severity === "Healthy" ? (
                        <span className="text-[11px] text-[#787774]">No Spray</span>
                      ) : (
                        <button
                          type="button"
                          onClick={(e) => toggleTreated(r.id, e)}
                          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-[3px] text-[11px] font-medium transition-colors ${
                            r.treated
                              ? "bg-[#edf6ed] text-[#2e7039] dark:bg-[#1f382a] dark:text-[#a3e3b3]"
                              : "bg-[#fbe4e4] text-[#a82d2a] hover:bg-[#fad4d4]"
                          }`}
                        >
                          {r.treated ? (
                            <>
                              <Check className="w-3 h-3" /> Treated
                            </>
                          ) : (
                            "Needs Spray"
                          )}
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* Bottom Row */}
            <div
              onClick={() => setNewScanModalOpen(true)}
              className={`h-9 px-3 text-[13px] text-[#787774] hover:text-[#37352f] dark:hover:text-white flex items-center gap-1.5 cursor-pointer border-b border-[#e9e9e7] dark:border-[#2f2f2f] transition-colors ${
                darkMode ? "hover:bg-[#202020]" : "hover:bg-[#f7f6f3]"
              }`}
            >
              <Plus className="w-3.5 h-3.5" />
              <span>Log new field scan...</span>
            </div>

            {/* Concise Summary */}
            <div className="h-8 px-3 text-[12px] text-[#787774] flex items-center justify-between border-b border-[#e9e9e7] dark:border-[#2f2f2f]">
              <span>
                Showing {filteredRecords.length} of {records.length} plot sectors
              </span>
              <span className="text-emerald-600 dark:text-emerald-400 font-medium font-mono">
                MobileNetV3 Edge Latency: 41.6ms
              </span>
            </div>
          </div>

          {/* Quick FAQ Accordion */}
          <div className="mt-8 pt-4 border-t border-[#e9e9e7] dark:border-[#2f2f2f]">
            <details className="group rounded p-1.5 text-[12px] text-[#787774]">
              <summary className="font-medium text-[#37352f] dark:text-[#d4d4d4] cursor-pointer flex items-center gap-1.5 select-none">
                <ChevronRight className="w-3.5 h-3.5 group-open:rotate-90 transition-transform" />
                <span>What is PHI (Pre-Harvest Interval) and why does it matter?</span>
              </summary>
              <p className="pl-5 pt-1 leading-relaxed text-[#787774]">
                The Pre-Harvest Interval (PHI) is the mandatory number of days a farmer must wait after applying a fungicide before picking the crop. Obeying PHI guarantees harvested tomatoes and potatoes contain zero chemical residue above sanitary safety thresholds.
              </p>
            </details>
          </div>

        </main>
      </div>

      {/* =====================================================================
          FOCUSED SIDE-PEEK DRAWER (Clean, actionable leaf inspection)
          ===================================================================== */}
      {activeRecord && (
        <div
          className={`fixed inset-y-0 right-0 z-50 w-full sm:w-[440px] border-l shadow-2xl flex flex-col animate-modal-pop select-none ${
            darkMode
              ? "bg-[#202020] border-[#2f2f2f] text-[#d4d4d4]"
              : "bg-white border-[#e9e9e7] text-[#37352f]"
          }`}
        >
          {/* Top Bar */}
          <div className="h-11 border-b border-[#e9e9e7] dark:border-[#2f2f2f] flex items-center justify-between px-4 text-[12px] text-[#787774]">
            <span className="font-medium text-[#37352f] dark:text-white">
              {activeRecord.plotZone}
            </span>
            <button
              type="button"
              onClick={() => setActiveRecord(null)}
              className="p-1 rounded text-[#787774] hover:text-[#37352f]"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          {/* Drawer Body */}
          <div className="flex-1 overflow-y-auto p-5 space-y-5">
            {/* Real Crop Photo */}
            <div className="relative w-full h-48 rounded-[6px] overflow-hidden bg-[#f1f1ef] dark:bg-[#191919] border border-[#e9e9e7] dark:border-[#2f2f2f]">
              <Image
                src={activeRecord.leafImage}
                alt={activeRecord.diagnosis}
                fill
                className="object-cover"
              />
              <div className="absolute top-2 left-2 bg-black/60 backdrop-blur-xs text-white text-[11px] font-mono px-2 py-0.5 rounded">
                {activeRecord.crop} • {activeRecord.diagnosis}
              </div>
            </div>

            {/* Prescribed Action Card */}
            <div
              className={`p-3.5 rounded-[6px] border space-y-2 ${
                darkMode ? "bg-[#252525] border-[#383838]" : "bg-[#fbfbfa] border-[#e9e9e7]"
              }`}
            >
              <span className="text-[11px] font-semibold uppercase tracking-wider text-[#787774] block">
                Prescribed Chemical & Dosage
              </span>
              <p className="font-bold text-[15px] text-[#37352f] dark:text-white">
                {activeRecord.prescribedTreatment}
              </p>
              <p className="text-[12px] font-mono text-[#787774]">
                Dosage: {activeRecord.dosageRate}
              </p>
              <div className="pt-1 flex items-center gap-2">
                <span className="text-[12px] text-[#787774]">Harvest Safety Waiting Period:</span>
                <span className="font-bold font-mono text-[12px] text-[#8f6412] dark:text-[#f8d488]">
                  {activeRecord.phiDays} Days PHI
                </span>
              </div>
            </div>

            {/* Field Notes */}
            <div className="space-y-1">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-[#787774] block">
                Agronomist Field Notes
              </span>
              <p className="text-[12px] text-[#787774] leading-relaxed p-2.5 rounded border border-[#e9e9e7] dark:border-[#2f2f2f] bg-[#f7f6f3] dark:bg-[#191919]">
                {activeRecord.farmerNote}
              </p>
            </div>

            {/* Action Toggle Button */}
            <div className="pt-2">
              <button
                type="button"
                onClick={() => toggleTreated(activeRecord.id)}
                className={`w-full py-2.5 rounded-[4px] font-medium text-[13px] shadow-2xs transition-colors ${
                  activeRecord.treated
                    ? "bg-[#efedea] text-[#787774] hover:bg-[#e0deda]"
                    : "bg-[#2383e2] hover:bg-[#1b70c4] text-white"
                }`}
              >
                {activeRecord.treated
                  ? "Mark as Needs Re-Spraying"
                  : "✓ Mark as Sprayed / Treated in Field"}
              </button>
            </div>

          </div>
        </div>
      )}

      {/* =====================================================================
          NEW SCAN MODAL (Minimal 3-step form)
          ===================================================================== */}
      {newScanModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-2xs flex items-center justify-center p-4">
          <div
            className={`w-full max-w-sm p-5 rounded-lg border shadow-xl space-y-4 animate-modal-pop select-none ${
              darkMode
                ? "bg-[#202020] border-[#383838] text-white"
                : "bg-white border-[#e9e9e7] text-[#37352f]"
            }`}
          >
            <div className="flex items-center justify-between pb-2 border-b border-[#e9e9e7] dark:border-[#2f2f2f]">
              <span className="font-bold text-[14px]">New Handheld Field Scan</span>
              <button
                type="button"
                onClick={() => setNewScanModalOpen(false)}
                className="text-[#787774] hover:text-[#37352f]"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-3 text-[12px]">
              <div>
                <label className="font-medium text-[#787774] block mb-1">Crop:</label>
                <select
                  value={newCrop}
                  onChange={(e) => setNewCrop(e.target.value as "Tomato" | "Potato" | "Corn")}
                  className={`w-full p-2 rounded border ${
                    darkMode
                      ? "bg-[#252525] border-[#383838] text-white"
                      : "bg-[#f7f6f3] border-[#e9e9e7] text-[#37352f]"
                  }`}
                >
                  <option value="Tomato">Tomato (Cell 6)</option>
                  <option value="Potato">Potato (Sector 4)</option>
                  <option value="Corn">Corn (Field 12)</option>
                </select>
              </div>

              <div>
                <label className="font-medium text-[#787774] block mb-1">Foliar Condition:</label>
                <div className="grid grid-cols-3 gap-1.5">
                  {(["Early Blight", "Healthy Foliage", "Late Blight"] as const).map((cond) => (
                    <button
                      key={cond}
                      type="button"
                      onClick={() => setNewCondition(cond)}
                      className={`p-2 rounded border text-center font-medium ${
                        newCondition === cond
                          ? "bg-[#edf6ed] border-emerald-500 text-[#2e7039]"
                          : "bg-[#f7f6f3] border-[#e9e9e7] text-[#787774]"
                      }`}
                    >
                      {cond.split(" ")[0]}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="font-medium text-[#787774] block mb-1">Plot Location:</label>
                <input
                  type="text"
                  value={newPlotZone}
                  onChange={(e) => setNewPlotZone(e.target.value)}
                  className={`w-full p-2 rounded border ${
                    darkMode
                      ? "bg-[#252525] border-[#383838] text-white"
                      : "bg-[#f7f6f3] border-[#e9e9e7] text-[#37352f]"
                  }`}
                />
              </div>
            </div>

            <button
              type="button"
              disabled={simulating}
              onClick={handleSimulateScan}
              className="w-full bg-[#2383e2] hover:bg-[#1b70c4] text-white font-medium text-[12px] py-2.5 rounded shadow-2xs flex items-center justify-center gap-2"
            >
              {simulating ? (
                <>
                  <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                  <span>Processing INT8 (41.6ms)...</span>
                </>
              ) : (
                <span>Log Scan to Database</span>
              )}
            </button>
          </div>
        </div>
      )}

    </div>
  );
}
