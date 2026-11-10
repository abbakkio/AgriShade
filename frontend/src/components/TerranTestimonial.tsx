"use client";

import React, { useState } from "react";
import Image from "next/image";

interface TestimonialItem {
  id: number;
  image: string;
  quote: string;
  name: string;
  role: string;
}

const testimonialList: TestimonialItem[] = [
  {
    id: 1,
    // Replaced low-res headshot with authentic high-res field photo matching the other cards
    image: "/assets/terran/OBww121K7TtHrQw0PGiAnkGO1o8.jpeg",
    quote:
      "AgriShadeNet completely changed how we think about our operations. We went from zero offline diagnostics to full real-time foliar disease detection in direct 35°C sun. If you're managing acreage across distributed fields, it's a must-have solution.",
    name: "Erbolat S.",
    role: "Chief Agronomist at Northern Steppe Agribusiness",
  },
  {
    id: 2,
    image: "/assets/terran/c08Kw62pCUpZaCP6P0XvD0jY4.jpeg",
    quote:
      "The offline dosage calculator alone prevented over 25% of fungicide waste across our greenhouse trials. The glove-friendly HUD interface means workers never have to remove protective equipment.",
    name: "Dina K.",
    role: "Precision Agriculture Specialist & Greenhouse Operator",
  },
  {
    id: 3,
    image: "/assets/terran/GYQI3k7e1zX4Mky2ozIgTX3zE.jpeg",
    quote:
      "Running sub-50ms inference on standard mobile phones without server latency is an engineering masterclass. The SQLite offline buffer reliably synced our records once we returned to base.",
    name: "Serik B.",
    role: "Farm Operations Manager at Kostanay Grain Enterprise",
  },
];

export default function TerranTestimonial() {
  const [currentIdx, setCurrentIdx] = useState(0);
  const current = testimonialList[currentIdx];

  const handleNext = () => {
    setCurrentIdx((prev) => (prev + 1) % testimonialList.length);
  };

  const handlePrev = () => {
    setCurrentIdx((prev) => (prev - 1 + testimonialList.length) % testimonialList.length);
  };

  return (
    <section className="py-28 bg-white border-t border-[#070d0c]/10">
      <div className="max-w-[1200px] mx-auto px-6">
        
        {/* Header */}
        <h2 className="text-[32px] sm:text-[44px] font-normal tracking-[-0.03em] text-[#070d0c] mb-16 text-center max-w-xl mx-auto leading-tight">
          Trusted by agronomists and farm owners across the country
        </h2>

        {/* 2-Column Split */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-10 md:gap-14 items-center">
          
          {/* Left Column: Photo (Matching the aesthetic of other cards) */}
          <div className="md:col-span-5 flex justify-center">
            <div className="relative w-full max-w-[360px] h-[420px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-slate-100">
              <Image
                src={current.image}
                alt={current.name}
                fill
                className="object-cover transition-opacity duration-300"
                sizes="(max-width: 768px) 100vw, 360px"
              />
            </div>
          </div>

          {/* Right Column: Quote + Attribution + Slider Controls */}
          <div className="md:col-span-7 flex flex-col justify-between h-full">
            <div>
              <p className="text-[24px] sm:text-[30px] font-normal leading-[1.35] tracking-[-0.02em] text-[#070d0c] mb-8">
                &ldquo;{current.quote}&rdquo;
              </p>

              <div className="flex flex-col mb-10">
                <span className="text-[18px] font-semibold text-[#070d0c]">
                  {current.name}
                </span>
                <span className="text-[14px] text-[#070d0c]/60">
                  {current.role}
                </span>
              </div>
            </div>

            {/* Slider Controls with Progress Bar and Arrows */}
            <div className="flex items-center gap-6 pt-6 border-t border-[#070d0c]/10">
              {/* Progress Bar */}
              <div className="flex-1 h-1 bg-gray-200 rounded-full overflow-hidden">
                <div
                  className="h-full bg-pine-900 transition-all duration-300"
                  style={{
                    width: `${((currentIdx + 1) / testimonialList.length) * 100}%`,
                  }}
                />
              </div>

              {/* Arrow Buttons */}
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={handlePrev}
                  className="w-10 h-10 rounded-full border border-[#070d0c]/20 hover:border-pine-900 flex items-center justify-center text-[#070d0c] hover:bg-pine-900 hover:text-white transition-all"
                  aria-label="Previous testimonial"
                >
                  ←
                </button>
                <button
                  type="button"
                  onClick={handleNext}
                  className="w-10 h-10 rounded-full border border-[#070d0c]/20 hover:border-pine-900 flex items-center justify-center text-[#070d0c] hover:bg-pine-900 hover:text-white transition-all"
                  aria-label="Next testimonial"
                >
                  →
                </button>
              </div>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
