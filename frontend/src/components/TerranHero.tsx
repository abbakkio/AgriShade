"use client";

import React from "react";
import Image from "next/image";
import { useAuth } from "@/context/AuthContext";

export default function TerranHero({ onOpenDemo }: { onOpenDemo: () => void }) {
  const { openAuthModal } = useAuth();

  // Mobile / tablet preview cards
  const mobileGalleryPhotos = [
    "/assets/terran/OBww121K7TtHrQw0PGiAnkGO1o8.jpeg",
    "/assets/terran/GYQI3k7e1zX4Mky2ozIgTX3zE.jpeg",
    "/assets/terran/c08Kw62pCUpZaCP6P0XvD0jY4.jpeg",
    "/assets/terran/5NUrDpF8tuF4NkxWxJSJg7Gvo.jpeg",
    "/assets/terran/JEOTupLCK3a4FmrD5kMIeyUU67g.jpeg",
    "/assets/terran/AcG32UNRukh7YUm0Ke7tEB4O6dQ.jpeg",
  ];

  return (
    <section
      className="relative bg-mint-bg min-h-[92vh] flex flex-col items-center justify-center overflow-hidden pt-36 sm:pt-40 pb-20 select-none"
      id="hero"
    >
      {/* =========================================================================
          DESKTOP FLANKING PHOTO CARDS (Mathematically clamped outside text boundary)
          Using calc(50% +/- 390px) ensures 0px text collision at any screen width.
          ========================================================================= */}
      <div className="absolute inset-0 pointer-events-none hidden xl:block overflow-hidden">
        
        {/* LEFT FLANK - OUTER COLUMN (Always visible on xl+) */}
        <div
          className="hero-photo-card absolute w-[210px] 2xl:w-[240px] h-[270px] 2xl:h-[310px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-white pointer-events-auto transition-transform duration-500 top-[110px] 2xl:top-[120px] left-4 2xl:left-10 -rotate-6 hover:rotate-0 hover:scale-105"
        >
          <Image
            src="/assets/terran/OBww121K7TtHrQw0PGiAnkGO1o8.jpeg"
            alt="AgriShadeNet Field Agronomy"
            fill
            className="object-cover"
            sizes="240px"
            priority
          />
        </div>

        <div
          className="hero-photo-card absolute w-[210px] 2xl:w-[240px] h-[270px] 2xl:h-[310px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-white pointer-events-auto transition-transform duration-500 top-[420px] 2xl:top-[460px] left-3 2xl:left-12 rotate-3 hover:rotate-0 hover:scale-105"
        >
          <Image
            src="/assets/terran/GYQI3k7e1zX4Mky2ozIgTX3zE.jpeg"
            alt="AgriShadeNet Soil & Canopy Sensor"
            fill
            className="object-cover"
            sizes="240px"
          />
        </div>

        {/* LEFT FLANK - INNER COLUMN (Visible on >= 1580px where ample horizontal space exists) */}
        <div
          style={{ right: "calc(50% + 380px)" }}
          className="hero-photo-card absolute hidden min-[1580px]:block w-[220px] 2xl:w-[240px] h-[280px] 2xl:h-[310px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-white pointer-events-auto transition-transform duration-500 top-[230px] 2xl:top-[250px] rotate-2 hover:rotate-0 hover:scale-105"
        >
          <Image
            src="/assets/terran/c08Kw62pCUpZaCP6P0XvD0jY4.jpeg"
            alt="AgriShadeNet Edge Triangulation"
            fill
            className="object-cover"
            sizes="240px"
          />
        </div>

        <div
          style={{ right: "calc(50% + 390px)" }}
          className="hero-photo-card absolute hidden min-[1580px]:block w-[220px] 2xl:w-[240px] h-[280px] 2xl:h-[310px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-white pointer-events-auto transition-transform duration-500 top-[560px] 2xl:top-[600px] -rotate-3 hover:rotate-0 hover:scale-105"
        >
          <Image
            src="/assets/terran/5NUrDpF8tuF4NkxWxJSJg7Gvo.jpeg"
            alt="AgriShadeNet Canopy Health Analysis"
            fill
            className="object-cover"
            sizes="240px"
          />
        </div>

        {/* RIGHT FLANK - INNER COLUMN (Visible on >= 1580px where ample horizontal space exists) */}
        <div
          style={{ left: "calc(50% + 380px)" }}
          className="hero-photo-card absolute hidden min-[1580px]:block w-[220px] 2xl:w-[240px] h-[280px] 2xl:h-[310px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-white pointer-events-auto transition-transform duration-500 top-[230px] 2xl:top-[250px] -rotate-2 hover:rotate-0 hover:scale-105"
        >
          <Image
            src="/assets/terran/JEOTupLCK3a4FmrD5kMIeyUU67g.jpeg"
            alt="AgriShadeNet Precision Triangulation"
            fill
            className="object-cover"
            sizes="240px"
          />
        </div>

        <div
          style={{ left: "calc(50% + 390px)" }}
          className="hero-photo-card absolute hidden min-[1580px]:block w-[220px] 2xl:w-[240px] h-[280px] 2xl:h-[310px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-white pointer-events-auto transition-transform duration-500 top-[560px] 2xl:top-[600px] rotate-3 hover:rotate-0 hover:scale-105"
        >
          <Image
            src="/assets/terran/CuKj1gcBs8CRxlXGZyDpUGYmIas.jpeg"
            alt="AgriShadeNet Field Verification"
            fill
            className="object-cover"
            sizes="240px"
          />
        </div>

        {/* RIGHT FLANK - OUTER COLUMN (Always visible on xl+) */}
        <div
          className="hero-photo-card absolute w-[210px] 2xl:w-[240px] h-[270px] 2xl:h-[310px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-white pointer-events-auto transition-transform duration-500 top-[110px] 2xl:top-[120px] right-4 2xl:right-10 rotate-6 hover:rotate-0 hover:scale-105"
        >
          <Image
            src="/assets/terran/AcG32UNRukh7YUm0Ke7tEB4O6dQ.jpeg"
            alt="AgriShadeNet Field Inspection"
            fill
            className="object-cover"
            sizes="240px"
            priority
          />
        </div>

        <div
          className="hero-photo-card absolute w-[210px] 2xl:w-[240px] h-[270px] 2xl:h-[310px] rounded-[24px] overflow-hidden shadow-[0_16px_40px_rgba(0,0,0,0.08)] bg-white pointer-events-auto transition-transform duration-500 top-[420px] 2xl:top-[460px] right-3 2xl:right-12 -rotate-3 hover:rotate-0 hover:scale-105"
        >
          <Image
            src="/assets/terran/BJUyRvkfPn00aw6sl9gerZgLljs.jpeg"
            alt="AgriShadeNet Field Agronomist Team"
            fill
            className="object-cover"
            sizes="240px"
          />
        </div>
      </div>

      {/* =========================================================================
          CENTRAL CONTENT (Clean, Unobstructed, Centered Column)
          ========================================================================= */}
      <div className="relative z-20 max-w-[700px] mx-auto px-6 text-center flex flex-col items-center">
        
        {/* Badge: Powering Your Success (Exact Terran Badge) */}
        <div className="mb-6 inline-flex items-center gap-2 bg-[#002e23]/[0.06] border border-[#002e23]/10 px-5 py-2 rounded-full">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          <span className="text-[13px] font-medium tracking-wide text-[#002e23]">
            Powering Your Success
          </span>
        </div>

        {/* Display Typography (Exact Terran Title) */}
        <h1 className="text-[42px] sm:text-[56px] md:text-[64px] font-normal tracking-[-0.035em] text-[#070d0c] leading-[1.06] mb-6">
          Grow your harvest.<br />
          Protect the planet.
        </h1>

        {/* Subtitle */}
        <p className="text-[16px] sm:text-[18px] text-[#070d0c]/75 leading-[1.5] max-w-[560px] mb-8 font-normal">
          AgriShadeNet equips agricultural enterprises and local farms to build resilient operations through offline edge AI diagnostics, compliance, and clarity.
        </p>

        {/* Action Buttons */}
        <div className="flex flex-wrap items-center justify-center gap-3.5 mb-10">
          <button
            type="button"
            onClick={() => openAuthModal("register")}
            className="bg-pine-900 hover:bg-pine-800 text-white font-medium text-[15px] sm:text-[16px] px-8 py-3.5 sm:py-4 rounded-full shadow-[0_4px_16px_rgba(0,46,35,0.18)] hover:shadow-lg transition-all"
          >
            Book a free consultation
          </button>
          <button
            type="button"
            onClick={onOpenDemo}
            className="bg-white hover:bg-gray-50 border border-[#070d0c]/15 text-[#070d0c] font-medium text-[15px] sm:text-[16px] px-7 py-3.5 sm:py-4 rounded-full transition-all shadow-2xs"
          >
            Launch Field HUD Demo
          </button>
        </div>

        {/* Mobile / Tablet Horizontal Gallery (Shown on < xl screens to prevent overlap) */}
        <div className="xl:hidden w-full max-w-lg mb-10 overflow-x-auto no-scrollbar flex items-center gap-3 py-2 px-1">
          {mobileGalleryPhotos.map((src, i) => (
            <div
              key={i}
              className="relative w-[140px] sm:w-[170px] h-[190px] sm:h-[220px] rounded-[18px] overflow-hidden shrink-0 shadow-sm"
            >
              <Image
                src={src}
                alt={`Field preview ${i}`}
                fill
                className="object-cover"
                sizes="170px"
              />
            </div>
          ))}
        </div>

        {/* Achievement Metrics Bar (Terran Exact Achievement) */}
        <div className="w-full flex flex-wrap items-center justify-center gap-6 sm:gap-12 pt-6 border-t border-[#070d0c]/10 text-center">
          <div className="flex flex-col items-center">
            <span className="text-[26px] sm:text-[32px] font-medium tracking-tight text-[#070d0c] leading-none mb-1">
              50<span className="text-emerald-600">+</span>
            </span>
            <span className="text-[12px] sm:text-[13px] text-[#070d0c]/60 font-normal">
              Farms Advised
            </span>
          </div>

          <div className="w-px h-8 bg-[#070d0c]/10 hidden sm:block" />

          <div className="flex flex-col items-center">
            <span className="text-[26px] sm:text-[32px] font-medium tracking-tight text-[#070d0c] leading-none mb-1">
              41.6<span className="text-emerald-600 text-base">ms</span>
            </span>
            <span className="text-[12px] sm:text-[13px] text-[#070d0c]/60 font-normal">
              On-Device Edge Latency
            </span>
          </div>

          <div className="w-px h-8 bg-[#070d0c]/10 hidden sm:block" />

          <div className="flex flex-col items-center">
            <span className="text-[26px] sm:text-[32px] font-medium tracking-tight text-[#070d0c] leading-none mb-1">
              98.7<span className="text-emerald-600">%</span>
            </span>
            <span className="text-[12px] sm:text-[13px] text-[#070d0c]/60 font-normal">
              Diagnostic Precision
            </span>
          </div>
        </div>

      </div>
    </section>
  );
}
