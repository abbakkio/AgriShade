import React from "react";
import Image from "next/image";

export default function TerranCompanyFootage() {
  return (
    <section className="py-24 bg-white border-t border-[#070d0c]/10">
      <div className="max-w-[1200px] mx-auto px-6">
        
        {/* Header */}
        <h2 className="text-[36px] sm:text-[50px] font-normal tracking-[-0.03em] text-[#070d0c] mb-10 leading-tight">
          Where strategy meets purpose.
        </h2>

        {/* Wide Cinematic Footage Card */}
        <div className="relative w-full h-[440px] sm:h-[540px] rounded-[28px] overflow-hidden bg-slate-900 shadow-[0_20px_50px_rgba(0,0,0,0.12)]">
          <Image
            src="/assets/terran/AOV5y2W1QxR1wVVfI3lCKb1NlvY.jpeg"
            alt="Company Footage"
            fill
            className="object-cover"
            sizes="(max-width: 1200px) 100vw, 1200px"
          />

          {/* Dark subtle gradient overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent flex flex-col justify-end p-8 sm:p-14">
            <p className="text-white text-[20px] sm:text-[28px] md:text-[34px] font-normal leading-snug tracking-[-0.02em] max-w-3xl">
              &ldquo;Our team works closely with every client — combining deep agronomic knowledge with a genuine commitment to sustainable outcomes.&rdquo;
            </p>
          </div>
        </div>

      </div>
    </section>
  );
}
