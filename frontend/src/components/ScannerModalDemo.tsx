"use client";

import React, { useState } from "react";
import Image from "next/image";
import { Play, Sparkles, Sun, X } from "lucide-react";

interface SampleItem {
  id: string;
  img: string;
  crop: string;
  disease: string;
  conf: string;
  entropy: string;
  severity: string;
  treatment: string;
  isOOD: boolean;
}

const sampleLeaves: SampleItem[] = [
  {
    id: "apple",
    img: "/assets/samples/cedar_apple_rust.jpg",
    crop: "Apple (Malus domestica)",
    disease: "Cedar Apple Rust",
    conf: "98.7%",
    entropy: "0.14 bits (High Certainty)",
    severity: "Severe (Level 3)",
    treatment: "Myclobutanil 1.25 L/ha",
    isOOD: false,
  },
  {
    id: "corn",
    img: "/assets/samples/corn_leaf_blight.jpg",
    crop: "Corn (Maize)",
    disease: "Northern Leaf Blight",
    conf: "96.4%",
    entropy: "0.22 bits (High Certainty)",
    severity: "Moderate (Level 2)",
    treatment: "Azoxystrobin 0.8 L/ha",
    isOOD: false,
  },
  {
    id: "tomato",
    img: "/assets/samples/healthy_tomato.jpg",
    crop: "Tomato (Solanum lycopersicum)",
    disease: "Healthy Leaf (No Pathogen)",
    conf: "99.2%",
    entropy: "0.06 bits (Optimal)",
    severity: "Zero Pathogens (Healthy)",
    treatment: "No chemical application required",
    isOOD: false,
  },
  {
    id: "ood",
    img: "/assets/samples/ood_houseplant_rejection.jpg",
    crop: "Non-Crop Flora",
    disease: "Out-of-Distribution Rejection",
    conf: "12.1%",
    entropy: "2.84 bits (High Uncertainty)",
    severity: "REJECTED (Non-Crop)",
    treatment: "Inspection aborted: Non-crop foliage",
    isOOD: true,
  },
];

export default function ScannerModalDemo({
  isOpen,
  onClose,
}: {
  isOpen: boolean;
  onClose: () => void;
}) {
  const [selectedSample, setSelectedSample] = useState<SampleItem>(sampleLeaves[0]);
  const [isScanning, setIsScanning] = useState(false);
  const [latencyText, setLatencyText] = useState("41.6 ms");
  const [sunlightMode, setSunlightMode] = useState(false);

  if (!isOpen) return null;

  const runDiagnostic = () => {
    setIsScanning(true);
    let step = 0;
    const interval = setInterval(() => {
      setLatencyText(`${(40.2 + Math.random() * 3.4).toFixed(1)} ms`);
      step++;
      if (step > 6) {
        clearInterval(interval);
      }
    }, 80);

    setTimeout(() => {
      setIsScanning(false);
      setLatencyText("41.6 ms");
    }, 700);
  };

  const handleSelectSample = (sample: SampleItem) => {
    setSelectedSample(sample);
    runDiagnostic();
  };

  const toggleSunlight = () => {
    setSunlightMode(!sunlightMode);
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-md"
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        className={`scanner-container relative w-full max-w-4xl rounded-[28px] p-6 sm:p-8 shadow-2xl animate-modal-pop border ${
          sunlightMode
            ? "bg-black border-cream text-white"
            : "bg-[#0b1310] border-white/15 text-white"
        }`}
      >
        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          className="absolute top-5 right-5 w-9 h-9 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors"
          aria-label="Close scanner dialog"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Modal Header */}
        <div className="flex items-center justify-between mb-6 pr-10">
          <div>
            <div className="flex items-center gap-2 text-xs font-bold tracking-wider text-emerald-400 mb-1">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
              <span>LIVE IN-FIELD EDGE INFERENCE</span>
            </div>
            <h2 className="text-xl sm:text-2xl font-semibold tracking-tight text-white">
              Cell 6 Real-Time Diagnostic HUD
            </h2>
          </div>

          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={toggleSunlight}
              className={`flex items-center gap-2 text-xs font-semibold px-3 py-1.5 rounded-full border transition-all ${
                sunlightMode
                  ? "bg-cream text-black border-cream"
                  : "bg-white/10 text-cream border-white/20 hover:bg-white/20"
              }`}
            >
              <Sun className="w-3.5 h-3.5" />
              <span>Direct Sunlight (WCAG AAA)</span>
            </button>
            <div className="font-mono text-xs font-bold text-cream bg-white/10 px-3 py-1.5 rounded-md">
              {latencyText}
            </div>
          </div>
        </div>

        {/* Content Layout */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
          
          {/* Left: Sample Selection */}
          <div className="md:col-span-5 flex flex-col gap-2.5">
            <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">
              Select Field Sample
            </span>
            {sampleLeaves.map((sample) => {
              const isSelected = selectedSample.id === sample.id;
              return (
                <button
                  key={sample.id}
                  type="button"
                  onClick={() => handleSelectSample(sample)}
                  className={`flex items-center gap-3 p-2.5 rounded-xl border text-left transition-all ${
                    isSelected
                      ? "bg-pine-900/80 border-sage shadow-md"
                      : "bg-white/[0.04] border-white/10 hover:bg-white/[0.08]"
                  }`}
                >
                  <div className="relative w-12 h-12 rounded-lg overflow-hidden shrink-0 bg-black">
                    <Image
                      src={sample.img}
                      alt={sample.crop}
                      fill
                      className="object-cover"
                      sizes="48px"
                    />
                  </div>
                  <div className="flex flex-col">
                    <strong className="text-xs sm:text-sm font-semibold text-white">
                      {sample.disease}
                    </strong>
                    <span className="text-[11px] text-gray-400">{sample.crop}</span>
                  </div>
                </button>
              );
            })}

            <button
              type="button"
              onClick={runDiagnostic}
              disabled={isScanning}
              className="mt-2 w-full py-3 px-4 rounded-full bg-sage text-pine-950 font-bold text-xs uppercase tracking-wider hover:bg-white transition-all flex items-center justify-center gap-2"
            >
              {isScanning ? (
                <Sparkles className="w-4 h-4 animate-spin" />
              ) : (
                <Play className="w-4 h-4 fill-current" />
              )}
              <span>Run Diagnostic Sweep (41.6ms)</span>
            </button>
          </div>

          {/* Right: Camera View & Telemetry */}
          <div className="md:col-span-7 flex flex-col gap-4">
            <div className="relative w-full h-56 sm:h-64 bg-black rounded-xl overflow-hidden border border-white/15">
              <Image
                src={selectedSample.img}
                alt={selectedSample.crop}
                fill
                className="object-cover"
                sizes="(max-width: 768px) 100vw, 480px"
              />

              {isScanning && (
                <div className="absolute inset-x-0 h-1 bg-gradient-to-r from-transparent via-cyan-400 to-transparent shadow-[0_0_15px_#22d3ee] animate-laser z-20" />
              )}

              {/* Reticle Overlay */}
              <div className="absolute inset-4 border border-dashed border-white/30 rounded-lg pointer-events-none">
                <div className="absolute top-0 left-0 w-3 h-3 border-t-2 border-l-2 border-sage" />
                <div className="absolute top-0 right-0 w-3 h-3 border-t-2 border-r-2 border-sage" />
                <div className="absolute bottom-0 left-0 w-3 h-3 border-b-2 border-l-2 border-sage" />
                <div className="absolute bottom-0 right-0 w-3 h-3 border-b-2 border-r-2 border-sage" />
              </div>

              {sunlightMode && (
                <div className="absolute bottom-3 left-3 bg-cream text-black text-[10px] font-bold px-2.5 py-1 rounded">
                  10,000+ LUX HIGH CONTRAST
                </div>
              )}
            </div>

            {/* 4 Telemetry Tiles */}
            <div className="grid grid-cols-2 gap-2.5">
              <div className="scanner-tile bg-white/[0.04] border border-white/10 rounded-xl p-2.5 flex flex-col gap-0.5">
                <span className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">
                  Condition
                </span>
                <span
                  className={`text-xs sm:text-sm font-bold truncate ${
                    selectedSample.isOOD ? "text-red-400" : "text-sage highlight"
                  }`}
                >
                  {selectedSample.disease}
                </span>
                <span className="text-[10px] text-gray-400 truncate">{selectedSample.crop}</span>
              </div>

              <div className="scanner-tile bg-white/[0.04] border border-white/10 rounded-xl p-2.5 flex flex-col gap-0.5">
                <span className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">
                  Confidence / Entropy
                </span>
                <span className="text-xs sm:text-sm font-bold text-white">
                  {selectedSample.conf}
                </span>
                <span className="text-[10px] text-gray-400 truncate">{selectedSample.entropy}</span>
              </div>

              <div className="scanner-tile bg-white/[0.04] border border-white/10 rounded-xl p-2.5 flex flex-col gap-0.5">
                <span className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">
                  Severity Tier
                </span>
                <span className="text-xs sm:text-sm font-bold text-white">
                  {selectedSample.severity}
                </span>
                <span className="text-[10px] text-gray-400">Canopy: Upper Tier</span>
              </div>

              <div className="scanner-tile bg-white/[0.04] border border-white/10 rounded-xl p-2.5 flex flex-col gap-0.5">
                <span className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">
                  Calibrated Dosage
                </span>
                <span
                  className={`text-xs sm:text-sm font-bold truncate ${
                    selectedSample.isOOD ? "text-red-400" : "text-cream"
                  }`}
                >
                  {selectedSample.treatment}
                </span>
                <span className="text-[10px] text-gray-400">200 L Water / Ha</span>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
