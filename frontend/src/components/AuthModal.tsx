"use client";

import React, { useState } from "react";
import { useAuth } from "@/context/AuthContext";
import { Loader2, X } from "lucide-react";

export default function AuthModal() {
  const {
    isAuthModalOpen,
    authModalTab,
    closeAuthModal,
    setAuthModalTab,
    login,
    register,
  } = useAuth();

  // Login form state
  const [loginUser, setLoginUser] = useState("");
  const [loginPass, setLoginPass] = useState("");

  // Register form state
  const [regFullName, setRegFullName] = useState("");
  const [regUsername, setRegUsername] = useState("");
  const [regEmail, setRegEmail] = useState("");
  const [regRole, setRegRole] = useState("agronomist");
  const [regFarmId, setRegFarmId] = useState("1");
  const [regPass, setRegPass] = useState("");

  // UI state
  const [loading, setLoading] = useState(false);
  const [alert, setAlert] = useState<{ type: "success" | "error"; msg: string } | null>(null);

  if (!isAuthModalOpen) return null;

  const handleLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setAlert(null);

    if (!loginUser || !loginPass) {
      setAlert({ type: "error", msg: "Please enter both username and password." });
      return;
    }

    setLoading(true);
    const result = await login(loginUser, loginPass);
    setLoading(false);

    if (result.success) {
      setAlert({ type: "success", msg: result.message || "Signed in successfully!" });
      setTimeout(() => {
        closeAuthModal();
      }, 700);
    } else {
      setAlert({ type: "error", msg: result.message || "Failed to sign in." });
    }
  };

  const handleRegisterSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setAlert(null);

    if (!regFullName || !regUsername || !regEmail || !regPass) {
      setAlert({ type: "error", msg: "Please fill in all required fields." });
      return;
    }

    setLoading(true);
    const result = await register({
      full_name: regFullName,
      username: regUsername,
      email: regEmail,
      role: regRole,
      farm_id: parseInt(regFarmId, 10) || 1,
      password: regPass,
    });
    setLoading(false);

    if (result.success) {
      setAlert({ type: "success", msg: result.message || "Account registered successfully!" });
      setTimeout(() => {
        closeAuthModal();
      }, 700);
    } else {
      setAlert({ type: "error", msg: result.message || "Registration failed." });
    }
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-charcoal/70 backdrop-blur-sm"
      onClick={(e) => {
        if (e.target === e.currentTarget) closeAuthModal();
      }}
    >
      <div className="relative w-full max-w-md bg-white rounded-3xl p-8 sm:p-9 shadow-2xl animate-modal border border-border-card">
        
        {/* Close Button */}
        <button
          type="button"
          onClick={closeAuthModal}
          className="absolute top-5 right-5 w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 text-charcoal flex items-center justify-center transition-colors"
          aria-label="Close dialog"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Modal Header */}
        <div className="text-center mb-6">
          <div className="w-9 h-9 rounded-lg bg-pine-900 mx-auto mb-3 flex items-center justify-center p-1.5 shadow-sm">
            <svg viewBox="0 0 24 24" fill="none" className="w-full h-full">
              <path
                d="M12 2C7.58 2 4 5.58 4 10C4 14.42 7.58 18 12 18C16.42 18 20 14.42 20 10C20 5.58 16.42 2 12 2Z"
                fill="#c7ebc7"
              />
              <circle cx="12" cy="10" r="3" fill="#faf9cf" />
            </svg>
          </div>
          <h2 id="modal-title" className="text-2xl font-bold tracking-tight text-charcoal">
            AgriShadeNet Portal
          </h2>
          <p className="text-xs text-muted-forest mt-1">
            Secure edge telemetry ingestion & agronomist identity management
          </p>
        </div>

        {/* Tab Switcher */}
        <div className="flex bg-gray-100 p-1 rounded-full mb-6 text-sm font-semibold">
          <button
            type="button"
            onClick={() => {
              setAlert(null);
              setAuthModalTab("login");
            }}
            className={`flex-1 py-2 rounded-full transition-all text-center ${
              authModalTab === "login"
                ? "bg-white text-pine-900 shadow-xs"
                : "text-muted-forest hover:text-charcoal"
            }`}
          >
            Sign In
          </button>
          <button
            type="button"
            onClick={() => {
              setAlert(null);
              setAuthModalTab("register");
            }}
            className={`flex-1 py-2 rounded-full transition-all text-center ${
              authModalTab === "register"
                ? "bg-white text-pine-900 shadow-xs"
                : "text-muted-forest hover:text-charcoal"
            }`}
          >
            Create Account
          </button>
        </div>

        {/* Alert Feedback */}
        {alert && (
          <div
            className={`p-3 rounded-xl text-xs font-semibold mb-5 flex items-center gap-2 ${
              alert.type === "success"
                ? "bg-emerald-50 text-emerald-800 border border-emerald-200"
                : "bg-red-50 text-red-800 border border-red-200"
            }`}
          >
            <span>{alert.msg}</span>
          </div>
        )}

        {/* ==================== SIGN IN FORM ==================== */}
        {authModalTab === "login" && (
          <form onSubmit={handleLoginSubmit} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5 text-left">
              <label className="text-xs font-semibold text-charcoal">
                Username or Email
              </label>
              <input
                type="text"
                value={loginUser}
                onChange={(e) => setLoginUser(e.target.value)}
                placeholder="e.g. erbolat_agronomist"
                required
                className="w-full px-3.5 py-2.5 rounded-xl border border-border-card text-sm bg-gray-50/50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-pine-900/20 focus:border-pine-900 transition-all text-charcoal"
              />
            </div>

            <div className="flex flex-col gap-1.5 text-left">
              <div className="flex justify-between items-center">
                <label className="text-xs font-semibold text-charcoal">Password</label>
                <a href="#" className="text-[11px] text-pine-900 font-medium hover:underline">
                  Forgot?
                </a>
              </div>
              <input
                type="password"
                value={loginPass}
                onChange={(e) => setLoginPass(e.target.value)}
                placeholder="••••••••••••"
                required
                className="w-full px-3.5 py-2.5 rounded-xl border border-border-card text-sm bg-gray-50/50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-pine-900/20 focus:border-pine-900 transition-all text-charcoal"
              />
            </div>

            <div className="flex items-center gap-2 text-xs text-muted-forest">
              <input
                type="checkbox"
                id="remember"
                defaultChecked
                className="rounded border-gray-300 text-pine-900 focus:ring-pine-900"
              />
              <label htmlFor="remember" className="select-none cursor-pointer">
                Remember session for offline sync
              </label>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 rounded-full bg-pine-900 hover:bg-pine-800 text-white font-semibold text-sm shadow-md transition-all flex items-center justify-center gap-2 mt-2 disabled:opacity-75"
            >
              {loading && <Loader2 className="w-4 h-4 animate-spin" />}
              <span>Sign In to Telemetry Portal</span>
            </button>

            <p className="text-center text-xs text-muted-forest mt-1">
              Don&apos;t have an account?{" "}
              <button
                type="button"
                onClick={() => setAuthModalTab("register")}
                className="text-pine-900 font-semibold underline"
              >
                Create one here
              </button>
            </p>
          </form>
        )}

        {/* ==================== CREATE ACCOUNT FORM ==================== */}
        {authModalTab === "register" && (
          <form onSubmit={handleRegisterSubmit} className="flex flex-col gap-3.5">
            <div className="flex flex-col gap-1 text-left">
              <label className="text-xs font-semibold text-charcoal">Full Name</label>
              <input
                type="text"
                value={regFullName}
                onChange={(e) => setRegFullName(e.target.value)}
                placeholder="e.g. Erbolat Sarsenov"
                required
                className="w-full px-3 py-2 rounded-xl border border-border-card text-sm bg-gray-50/50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-pine-900/20 focus:border-pine-900 transition-all text-charcoal"
              />
            </div>

            <div className="grid grid-cols-2 gap-2.5">
              <div className="flex flex-col gap-1 text-left">
                <label className="text-xs font-semibold text-charcoal">Username</label>
                <input
                  type="text"
                  value={regUsername}
                  onChange={(e) => setRegUsername(e.target.value)}
                  placeholder="e.g. erbolat_s"
                  required
                  className="w-full px-3 py-2 rounded-xl border border-border-card text-sm bg-gray-50/50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-pine-900/20 focus:border-pine-900 transition-all text-charcoal"
                />
              </div>
              <div className="flex flex-col gap-1 text-left">
                <label className="text-xs font-semibold text-charcoal">Email</label>
                <input
                  type="email"
                  value={regEmail}
                  onChange={(e) => setRegEmail(e.target.value)}
                  placeholder="e.g. erbolat@farm.kz"
                  required
                  className="w-full px-3 py-2 rounded-xl border border-border-card text-sm bg-gray-50/50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-pine-900/20 focus:border-pine-900 transition-all text-charcoal"
                />
              </div>
            </div>

            <div className="flex flex-col gap-1 text-left">
              <label className="text-xs font-semibold text-charcoal">Role</label>
              <select
                value={regRole}
                onChange={(e) => setRegRole(e.target.value)}
                className="w-full px-3 py-2 rounded-xl border border-border-card text-sm bg-gray-50/50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-pine-900/20 focus:border-pine-900 transition-all text-charcoal"
              >
                <option value="agronomist">Lead Agronomist</option>
                <option value="farmer">Specialist</option>
                <option value="admin">Agribusiness Admin</option>
                <option value="researcher">Researcher</option>
              </select>
            </div>

            <div className="flex flex-col gap-1 text-left">
              <label className="text-xs font-semibold text-charcoal">Password</label>
              <input
                type="password"
                value={regPass}
                onChange={(e) => setRegPass(e.target.value)}
                placeholder="Min. 8 characters"
                required
                className="w-full px-3 py-2 rounded-xl border border-border-card text-sm bg-gray-50/50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-pine-900/20 focus:border-pine-900 transition-all text-charcoal"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 rounded-full bg-pine-900 hover:bg-pine-800 text-white font-semibold text-sm shadow-md transition-all flex items-center justify-center gap-2 mt-2 disabled:opacity-75"
            >
              {loading && <Loader2 className="w-4 h-4 animate-spin" />}
              <span>Create Authorized Account</span>
            </button>

            <p className="text-center text-xs text-muted-forest mt-1">
              Already registered?{" "}
              <button
                type="button"
                onClick={() => setAuthModalTab("login")}
                className="text-pine-900 font-semibold underline"
              >
                Sign in here
              </button>
            </p>
          </form>
        )}

      </div>
    </div>
  );
}
