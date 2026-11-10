"use client";

import React from "react";
import { useAuth } from "@/context/AuthContext";

export default function TerranPreFooter() {
  const { openAuthModal } = useAuth();

  return (
    <section className="py-28 sm:py-36 bg-white border-t border-[#070d0c]/10 text-center flex flex-col items-center px-6">
      <div className="max-w-[1000px] mx-auto flex flex-col items-center">
        
        {/* Massive Display Text */}
        <h2 className="text-[34px] sm:text-[56px] md:text-[68px] font-normal leading-[1.08] tracking-[-0.035em] text-[#070d0c] mb-10 max-w-4xl">
          Integrated sustainability &amp; green precision agriculture with AgriShadeNet
        </h2>

        {/* Pill CTA Button */}
        <button
          type="button"
          onClick={() => openAuthModal("register")}
          className="bg-pine-900 hover:bg-pine-800 text-white font-medium text-[16px] px-9 py-4 rounded-full shadow-[0_4px_16px_rgba(0,46,35,0.18)] hover:shadow-lg transition-all"
        >
          Book a Free Consultation
        </button>

      </div>
    </section>
  );
}
