"use client";

import React, { useState } from "react";
import Image from "next/image";

interface ProcessStep {
  id: number;
  title: string;
  desc: string;
  image: string;
}

const steps: ProcessStep[] = [
  {
    id: 1,
    title: "Discovery & Assessment",
    desc: "We start by understanding your farm — your operations, pathogen risks, and environmental footprint. No assumptions, just clarity.",
    image: "/assets/terran/c08Kw62pCUpZaCP6P0XvD0jY4.jpeg",
  },
  {
    id: 2,
    title: "Strategy & Roadmap",
    desc: "We build a tailored precision agriculture roadmap aligned with your acreage goals, chemical safety, and compliance requirements.",
    image: "/assets/terran/JEOTupLCK3a4FmrD5kMIeyUU67g.jpeg",
  },
  {
    id: 3,
    title: "Implementation Support",
    desc: "Our 41.6ms offline edge model works alongside your field agronomists — ensuring every diagnosis is immediate, calibrated, and sustainable.",
    image: "/assets/terran/AcG32UNRukh7YUm0Ke7tEB4O6dQ.jpeg",
  },
  {
    id: 4,
    title: "Reporting & Growth",
    desc: "We track disease containment, log GPS telemetry in local SQLite, and continuously refine treatment protocols as your farm expands.",
    image: "/assets/terran/GYQI3k7e1zX4Mky2ozIgTX3zE.jpeg",
  },
];

export default function TerranProcess() {
  const [activeId, setActiveId] = useState(1);
  const activeStep = steps.find((s) => s.id === activeId) || steps[0];

  return (
    <section className="py-28 bg-white border-t border-[#070d0c]/10" id="process">
      <div className="max-w-[1200px] mx-auto px-6">
        
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-16 items-center">
          
          {/* Left Column: Titles & 4 Interactive Stages */}
          <div className="lg:col-span-6 flex flex-col">
            <h2 className="text-[36px] sm:text-[46px] font-normal tracking-[-0.03em] text-[#070d0c] leading-[1.1] mb-3">
              Clear strategy.<br />
              Measurable results.
            </h2>
            <p className="text-[16px] text-[#070d0c]/70 leading-relaxed mb-10 max-w-md">
              We guide you through every step — from initial assessment to long-term impact.
            </p>

            <div className="flex flex-col gap-3">
              {steps.map((step) => {
                const isActive = step.id === activeId;
                return (
                  <div
                    key={step.id}
                    onClick={() => setActiveId(step.id)}
                    className={`cursor-pointer rounded-[20px] p-6 transition-all duration-300 border ${
                      isActive
                        ? "bg-[#070d0c]/[0.03] border-[#070d0c]/20 shadow-xs"
                        : "bg-transparent border-transparent hover:bg-[#070d0c]/[0.015]"
                    }`}
                  >
                    <div className="flex items-center gap-3.5 mb-2">
                      <span
                        className={`w-2.5 h-2.5 rounded-full transition-colors ${
                          isActive ? "bg-pine-900" : "bg-gray-300"
                        }`}
                      />
                      <h3 className="text-[19px] font-medium text-[#070d0c]">
                        {step.title}
                      </h3>
                    </div>

                    <p
                      className={`text-[14px] leading-relaxed text-[#070d0c]/70 pl-6 transition-all ${
                        isActive ? "block" : "hidden sm:block opacity-60"
                      }`}
                    >
                      {step.desc}
                    </p>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Right Column: Media Preview (Matching Terran Media) */}
          <div className="lg:col-span-6 flex justify-center">
            <div className="relative w-full max-w-[540px] h-[520px] sm:h-[580px] rounded-[24px] overflow-hidden shadow-[0_20px_50px_rgba(0,0,0,0.08)] bg-slate-100">
              <Image
                src={activeStep.image}
                alt={activeStep.title}
                fill
                className="object-cover transition-opacity duration-500"
                sizes="(max-width: 1024px) 100vw, 540px"
              />
              <div className="absolute bottom-5 left-5 bg-white/90 backdrop-blur-md px-4 py-2 rounded-full text-xs font-semibold text-pine-900">
                0{activeStep.id} — {activeStep.title}
              </div>
            </div>
          </div>

        </div>

      </div>
    </section>
  );
}
