"use client";

import React, { useState } from "react";
import TerranNavbar from "@/components/TerranNavbar";
import TerranHero from "@/components/TerranHero";
import TerranAbout from "@/components/TerranAbout";
import TerranProcess from "@/components/TerranProcess";
import TerranServices from "@/components/TerranServices";
import TerranTestimonial from "@/components/TerranTestimonial";
import TerranProjects from "@/components/TerranProjects";
import TerranCompanyFootage from "@/components/TerranCompanyFootage";
import TerranBlog from "@/components/TerranBlog";
import TerranPreFooter from "@/components/TerranPreFooter";
import TerranFooter from "@/components/TerranFooter";
import AuthModal from "@/components/AuthModal";
import ScannerModalDemo from "@/components/ScannerModalDemo";

export default function Home() {
  const [scannerDemoOpen, setScannerDemoOpen] = useState(false);

  return (
    <div className="flex flex-col min-h-screen bg-white selection:bg-sage selection:text-pine-950">
      {/* Floating Pill Navbar */}
      <TerranNavbar />

      <main className="flex-1">
        {/* Authentic Terran Hero with 12-Photo Parabolic Arc */}
        <TerranHero onOpenDemo={() => setScannerDemoOpen(true)} />

        {/* Large Manifesto Quote */}
        <TerranAbout />

        {/* 4-Step Process Section with Media */}
        <TerranProcess />

        {/* Terran Signature Pill Services Cards */}
        <TerranServices />

        {/* Split Testimonial Slider with Progress Bar */}
        <TerranTestimonial />

        {/* Featured Projects Grid */}
        <TerranProjects />

        {/* Wide Cinematic Company Footage Banner */}
        <TerranCompanyFootage />

        {/* Insights From The Field (Blog) */}
        <TerranBlog />

        {/* Pre-Footer Massive Headline */}
        <TerranPreFooter />
      </main>

      {/* Footer with Iconic Geometric Art Box */}
      <TerranFooter />

      {/* Auth Modal (Login / Register) */}
      <AuthModal />

      {/* Interactive In-Field Scanner HUD Demo Modal */}
      <ScannerModalDemo
        isOpen={scannerDemoOpen}
        onClose={() => setScannerDemoOpen(false)}
      />
    </div>
  );
}
