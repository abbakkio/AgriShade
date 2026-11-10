import React from "react";

export default function TerranFooter() {
  return (
    <footer className="bg-pine-900 text-[#faf9cf] pt-20 pb-0 overflow-hidden">
      <div className="max-w-[1200px] mx-auto px-6 mb-16">
        
        {/* Top Grid */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-10 pb-16 border-b border-[#faf9cf]/15">
          
          {/* Brand Logo & Description */}
          <div className="md:col-span-6 flex flex-col gap-4">
            <div className="flex items-center gap-2.5">
              <div className="w-[33px] h-[33px] rounded-[10px] bg-[#faf9cf] flex items-center justify-center p-1.5">
                <svg viewBox="0 0 24 24" fill="none" className="w-full h-full">
                  <rect width="24" height="24" rx="6" fill="#faf9cf" />
                  <circle cx="12" cy="12" r="5" fill="#002e23" />
                  <circle cx="12" cy="12" r="2.5" fill="#faf9cf" />
                </svg>
              </div>
              <span className="font-semibold text-[22px] tracking-tight text-[#faf9cf]">
                AgriShadeNet
              </span>
            </div>
            <p className="text-[14px] text-[#faf9cf]/70 max-w-sm leading-relaxed">
              Precision agriculture, environmental compliance, and edge AI diagnostics for sustainable farming operations.
            </p>
          </div>

          {/* Links: Company */}
          <div className="md:col-span-3 flex flex-col gap-3">
            <span className="text-[13px] font-bold tracking-wider uppercase text-[#faf9cf] opacity-80 mb-1">
              Platform
            </span>
            <ul className="flex flex-col gap-2.5 text-[15px] text-[#faf9cf]/75 font-normal">
              <li><a href="#hero" className="hover:text-white transition-colors">Home</a></li>
              <li><a href="#about" className="hover:text-white transition-colors">About</a></li>
              <li><a href="#projects" className="hover:text-white transition-colors">Projects</a></li>
              <li><a href="#services" className="hover:text-white transition-colors">Services</a></li>
              <li><a href="#blog" className="hover:text-white transition-colors">Blog</a></li>
            </ul>
          </div>

          {/* Links: Legals */}
          <div className="md:col-span-3 flex flex-col gap-3">
            <span className="text-[13px] font-bold tracking-wider uppercase text-[#faf9cf] opacity-80 mb-1">
              Legals &amp; Standards
            </span>
            <ul className="flex flex-col gap-2.5 text-[15px] text-[#faf9cf]/75 font-normal">
              <li><a href="#about" className="hover:text-white transition-colors">Terms &amp; Condition</a></li>
              <li><a href="#about" className="hover:text-white transition-colors">Privacy policy</a></li>
              <li><a href="#about" className="hover:text-white transition-colors">ISO/IEC 25010 Standards</a></li>
              <li><a href="#about" className="hover:text-white transition-colors">WCAG 2.1 AAA Accessibility</a></li>
            </ul>
          </div>

        </div>

        {/* Bottom Bar: Copyright & Socials */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-8 text-[14px] text-[#faf9cf]/60">
          <div>
            AgriShadeNet © 2026 all rights reserved · Astana IT University (AITU)
          </div>
          <div className="flex items-center gap-6 text-[#faf9cf]/80 font-medium">
            <a href="https://github.com/abbakkio/AgriShade" target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors">
              GitHub
            </a>
            <a href="https://www.canva.com/d/ZVf_YENfZpsNcy5" target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors">
              Canva
            </a>
            <a href="https://aitu.edu.kz" target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors">
              AITU
            </a>
          </div>
        </div>

      </div>

      {/* =========================================================================
          THE ICONIC FOOTER VISUALS (526px Art Box with AgriShadeNet Identity)
          ========================================================================= */}
      <div className="w-full bg-[#faf9cf] h-[360px] sm:h-[480px] p-8 sm:p-14 flex items-center justify-center relative overflow-hidden">
        {/* Layer 1 */}
        <div className="w-full max-w-[1100px] h-full rounded-[32px] sm:rounded-[44px] bg-pine-900 flex items-center justify-center p-6 sm:p-12 relative shadow-2xl">
          {/* Layer 2 */}
          <div className="w-full h-full rounded-[24px] sm:rounded-[36px] bg-[#faf9cf] flex items-center justify-center p-6 sm:p-10">
            {/* Layer 3 */}
            <div className="w-full h-full rounded-[18px] sm:rounded-[28px] bg-pine-900 flex flex-col items-center justify-center text-center p-6 shadow-inner">
              <div className="w-16 h-16 rounded-[18px] bg-[#faf9cf] flex items-center justify-center mb-4 p-3 shadow-md">
                <svg viewBox="0 0 24 24" fill="none" className="w-full h-full">
                  <rect width="24" height="24" rx="6" fill="#faf9cf" />
                  <circle cx="12" cy="12" r="6" fill="#002e23" />
                  <circle cx="12" cy="12" r="3" fill="#faf9cf" />
                </svg>
              </div>
              <span className="text-[28px] sm:text-[40px] font-semibold text-[#faf9cf] tracking-tight">
                AgriShadeNet
              </span>
              <span className="text-xs sm:text-sm text-[#faf9cf]/70 tracking-widest uppercase mt-1">
                Precision Agriculture &amp; Environmental Intelligence
              </span>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
