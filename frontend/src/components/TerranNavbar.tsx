"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useAuth } from "@/context/AuthContext";
import { LogOut, Menu, X, LayoutDashboard } from "lucide-react";

export default function TerranNavbar() {
  const { user, openAuthModal, logout } = useAuth();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="sticky top-5 z-50 w-full px-4 flex justify-center">
      <nav
        aria-label="Main Navigation"
        className="w-full max-w-[1200px] h-[60px] bg-white border border-[#e5e5e6] rounded-full flex items-center justify-between px-6 shadow-[0_4px_20px_rgba(0,0,0,0.03)] transition-all"
      >
        {/* Brand Logo: AgriShadeNet */}
        <Link href="/" className="flex items-center gap-2.5 group">
          <div className="w-[33px] h-[33px] rounded-[10px] bg-pine-900 flex items-center justify-center p-1.5 shadow-sm transition-transform group-hover:scale-105">
            <svg viewBox="0 0 24 24" fill="none" className="w-full h-full">
              <rect width="24" height="24" rx="6" fill="#002e23" />
              <circle cx="12" cy="12" r="5" fill="#faf9cf" />
              <circle cx="12" cy="12" r="2.5" fill="#002e23" />
            </svg>
          </div>
          <span className="font-semibold text-[19px] tracking-tight text-[#070d0c] group-hover:text-pine-900 transition-colors">
            AgriShadeNet
          </span>
        </Link>

        {/* Desktop Nav Links */}
        <ul className="hidden md:flex items-center gap-7">
          <li>
            <Link
              href="/#hero"
              className="text-[15px] font-medium text-[#070d0c] hover:text-pine-900 transition-colors"
            >
              Home
            </Link>
          </li>
          <li>
            <Link
              href="/#about"
              className="text-[15px] font-medium text-[#070d0c] hover:text-pine-900 transition-colors"
            >
              About
            </Link>
          </li>
          <li>
            <Link
              href="/#process"
              className="text-[15px] font-medium text-[#070d0c] hover:text-pine-900 transition-colors"
            >
              Process
            </Link>
          </li>
          <li>
            <Link
              href="/#services"
              className="text-[15px] font-medium text-[#070d0c] hover:text-pine-900 transition-colors"
            >
              Services
            </Link>
          </li>
          <li>
            <Link
              href="/#projects"
              className="text-[15px] font-medium text-[#070d0c] hover:text-pine-900 transition-colors"
            >
              Projects
            </Link>
          </li>
          <li>
            <Link
              href="/#blog"
              className="text-[15px] font-medium text-[#070d0c] hover:text-pine-900 transition-colors"
            >
              Blogs
            </Link>
          </li>
          <li>
            <Link
              href="/dashboard"
              className="inline-flex items-center gap-1.5 text-[14px] font-medium text-[#002e23] bg-[#ecfdf5] hover:bg-[#d1fae5] border border-emerald-600/20 px-3.5 py-1.5 rounded-full transition-all"
            >
              <LayoutDashboard className="w-3.5 h-3.5 text-emerald-700" />
              <span>Dashboard</span>
            </Link>
          </li>
        </ul>

        {/* CTA & Auth Group */}
        <div className="flex items-center gap-3">
          {user ? (
            <div className="flex items-center gap-2">
              <Link
                href="/dashboard"
                className="flex items-center gap-2 bg-mint-bg hover:bg-emerald-100/60 border border-pine-900/15 py-1.5 px-3.5 rounded-full transition-colors"
              >
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                <span className="text-xs font-semibold text-[#070d0c]">
                  {user.full_name || user.username}
                </span>
              </Link>
              <button
                type="button"
                onClick={logout}
                title="Sign Out"
                className="p-1.5 text-gray-500 hover:text-red-500 transition-colors"
                aria-label="Sign Out"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => openAuthModal("login")}
                className="hidden sm:inline-block text-[14px] font-medium text-[#070d0c] hover:text-pine-900 px-3 py-1.5 transition-colors"
              >
                Sign In
              </button>
              <button
                type="button"
                onClick={() => openAuthModal("register")}
                className="bg-pine-900 hover:bg-pine-800 text-white text-[14px] font-medium px-5 py-2 rounded-full shadow-xs hover:shadow transition-all"
              >
                Get Started
              </button>
            </div>
          )}

          {/* Mobile hamburger */}
          <button
            type="button"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden text-[#070d0c] p-1.5"
            aria-label="Toggle menu"
          >
            {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
      </nav>

      {/* Mobile Drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden absolute top-[72px] left-4 right-4 bg-white border border-[#e5e5e6] rounded-[24px] p-6 shadow-2xl flex flex-col gap-4 animate-modal-pop">
          <ul className="flex flex-col gap-3.5">
            {["Home", "About", "Process", "Services", "Projects", "Blogs"].map((item) => (
              <li key={item}>
                <Link
                  href={`/#${item.toLowerCase()}`}
                  onClick={() => setMobileMenuOpen(false)}
                  className="block text-[16px] font-medium text-[#070d0c] hover:text-pine-900"
                >
                  {item}
                </Link>
              </li>
            ))}
            <li className="pt-2 border-t border-gray-100">
              <Link
                href="/dashboard"
                onClick={() => setMobileMenuOpen(false)}
                className="flex items-center gap-2 text-[16px] font-medium text-emerald-800"
              >
                <LayoutDashboard className="w-4 h-4" />
                <span>Dashboard (Notion Style)</span>
              </Link>
            </li>
          </ul>

          <div className="pt-4 border-t border-gray-100 flex flex-col gap-2.5">
            {user ? (
              <div className="flex items-center justify-between">
                <span className="text-sm font-semibold text-[#070d0c]">
                  Signed in as {user.full_name || user.username}
                </span>
                <button
                  type="button"
                  onClick={logout}
                  className="text-xs text-red-600 font-medium hover:underline"
                >
                  Sign Out
                </button>
              </div>
            ) : (
              <>
                <button
                  type="button"
                  onClick={() => {
                    setMobileMenuOpen(false);
                    openAuthModal("login");
                  }}
                  className="w-full text-center py-2.5 text-[15px] font-medium text-[#070d0c] bg-gray-50 rounded-full"
                >
                  Sign In
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setMobileMenuOpen(false);
                    openAuthModal("register");
                  }}
                  className="w-full text-center py-2.5 text-[15px] font-medium text-white bg-pine-900 rounded-full"
                >
                  Get Started
                </button>
              </>
            )}
          </div>
        </div>
      )}
    </header>
  );
}
