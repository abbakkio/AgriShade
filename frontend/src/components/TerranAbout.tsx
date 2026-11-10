import React from "react";

export default function TerranAbout() {
  return (
    <section
      className="py-32 sm:py-40 bg-white border-t border-[#070d0c]/10 text-center flex flex-col items-center justify-center px-6"
      id="about"
    >
      <div className="max-w-[960px] mx-auto flex flex-col items-center">
        {/* Giant Manifesto Quote */}
        <p className="text-[28px] sm:text-[42px] md:text-[48px] font-normal leading-[1.3] tracking-[-0.03em] text-[#070d0c] mb-12">
          &ldquo;AgriShadeNet was built for farms ready to grow responsibly. We turn environmental complexity into clear strategy — so you can focus on building what matters.&rdquo;
        </p>

        {/* Author / Company Credit */}
        <div className="flex flex-col items-center gap-1">
          <span className="text-[17px] font-semibold text-[#070d0c]">
            Azat Madiyev
          </span>
          <span className="text-[14px] text-[#070d0c]/60">
            Founder &amp; Lead AI Researcher · Astana IT University (AITU)
          </span>
        </div>
      </div>
    </section>
  );
}
