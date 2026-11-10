"use client";

import React, { useState } from "react";
import { useAuth } from "@/context/AuthContext";

interface ServiceItem {
  id: string;
  num: string;
  title: string;
  desc: string;
  details: string;
}

const servicesList: ServiceItem[] = [
  {
    id: "esg",
    num: "01",
    title: "Offline Foliar Disease Diagnosis",
    desc: "We deploy quantized MobileNetV3 models directly on mobile devices — giving you instant, offline pathogen detection in under 42ms.",
    details:
      "Eliminates dependency on fragile rural cellular networks. Classifies wheat leaf rust, corn northern leaf blight, powdery mildew, and tomato septoria instantly with 98.7% accuracy.",
  },
  {
    id: "compliance",
    num: "02",
    title: "Environmental Sunlight Compliance (WCAG 2.1 AAA)",
    desc: "We engineer high-contrast outdoor interfaces that exceed 7.5:1 contrast ratios — so field workers never struggle under 10,000+ lux summer sun.",
    details:
      "Includes glove-friendly 48+ dp touch targets and direct-sun optical glare suppression designed for tough Central Asian field conditions.",
  },
  {
    id: "energy",
    num: "03",
    title: "Precision Chemical Dosage Engine",
    desc: "We calibrate mathematical dosage formulas to the exact foliar infection tier — turning chemical safety into a genuine cost reduction.",
    details:
      "Prevents hazardous over-spraying, cuts input expenditures by up to 28%, and protects beneficial soil micro-ecology from chemical runoff.",
  },
  {
    id: "green",
    num: "04",
    title: "Edge-to-Cloud Telemetry Synchronization",
    desc: "We integrate resilient local SQLite write-ahead logging with centralized cloud dashboards — keeping audit trails 100% loss-free.",
    details:
      "Enables multi-farm holding companies to track regional epidemiology, device telemetry, and agronomist treatments with SHA-256 HMAC integrity.",
  },
];

export default function TerranServices() {
  const { openAuthModal } = useAuth();
  const [expandedId, setExpandedId] = useState<string>("esg");

  return (
    <section className="py-28 bg-white border-t border-[#070d0c]/10" id="services">
      <div className="max-w-[1200px] mx-auto px-6">
        
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-16">
          <h2 className="text-[38px] sm:text-[54px] md:text-[62px] font-normal tracking-[-0.03em] text-[#070d0c] leading-[1.05]">
            What we help you with
          </h2>
          <button
            type="button"
            onClick={() => openAuthModal("register")}
            className="self-start md:self-auto bg-pine-900 hover:bg-pine-800 text-white font-medium text-[15px] px-7 py-3.5 rounded-full transition-all shadow-xs"
          >
            Book a free consultation
          </button>
        </div>

        {/* Terran Pill Services Cards */}
        <div className="flex flex-col gap-4">
          {servicesList.map((service) => {
            const isExpanded = expandedId === service.id;
            return (
              <div
                key={service.id}
                onClick={() => setExpandedId(isExpanded ? "" : service.id)}
                className={`cursor-pointer rounded-[24px] sm:rounded-full p-6 sm:px-10 sm:py-7 transition-all duration-300 border ${
                  isExpanded
                    ? "bg-[#faf9cf] border-[#070d0c]/15 shadow-sm"
                    : "bg-[#faf9cf]/70 border-transparent hover:bg-[#faf9cf]"
                }`}
              >
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div className="flex items-center gap-4">
                    <span className="text-[15px] font-bold text-[#070d0c]/50">
                      {service.num}
                    </span>
                    <h3 className="text-[20px] sm:text-[23px] font-normal text-[#070d0c] tracking-tight">
                      {service.title}:
                    </h3>
                  </div>

                  <span className="text-sm text-[#070d0c]/70 sm:max-w-md line-clamp-1 font-normal">
                    {service.desc}
                  </span>

                  <span className="text-xl text-[#070d0c] transition-transform duration-300 self-end sm:self-auto">
                    {isExpanded ? "↑" : "→"}
                  </span>
                </div>

                {isExpanded && (
                  <div className="mt-4 pt-4 border-t border-[#070d0c]/10 text-sm text-[#070d0c]/80 leading-relaxed max-w-3xl">
                    <p className="mb-2">{service.desc}</p>
                    <p className="text-xs text-[#070d0c]/60 font-medium">{service.details}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
