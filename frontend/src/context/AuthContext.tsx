"use client";

import React, { createContext, useContext, useEffect, useState } from "react";

export interface UserSession {
  username: string;
  full_name: string;
  email?: string;
  role: string;
  farm_id: number;
  token: string;
}

interface AuthContextType {
  user: UserSession | null;
  isAuthModalOpen: boolean;
  authModalTab: "login" | "register";
  openAuthModal: (tab?: "login" | "register") => void;
  closeAuthModal: () => void;
  setAuthModalTab: (tab: "login" | "register") => void;
  login: (username: string, password: string) => Promise<{ success: boolean; message?: string }>;
  register: (payload: {
    username: string;
    email: string;
    password: string;
    full_name: string;
    role: string;
    farm_id: number;
  }) => Promise<{ success: boolean; message?: string }>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const SESSION_STORAGE_KEY = "agrishadenet_user_session";

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserSession | null>(null);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [authModalTab, setAuthModalTab] = useState<"login" | "register">("login");

  // Restore session from localStorage on mount
  useEffect(() => {
    try {
      const stored = localStorage.getItem(SESSION_STORAGE_KEY);
      if (stored) {
        setUser(JSON.parse(stored));
      }
    } catch (e) {
      console.warn("Failed to read user session from storage", e);
    }
  }, []);

  const openAuthModal = (tab: "login" | "register" = "login") => {
    setAuthModalTab(tab);
    setIsAuthModalOpen(true);
  };

  const closeAuthModal = () => {
    setIsAuthModalOpen(false);
  };

  const API_BASE = process.env.NEXT_PUBLIC_API_URL || "https://agrishade.onrender.com";

  const login = async (username: string, password: string) => {
    try {
      const res = await fetch(`${API_BASE}/api/v1/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      });

      if (res.ok) {
        const data = await res.json();
        const session: UserSession = {
          username: data.user.username,
          full_name: data.user.full_name || username,
          email: data.user.email,
          role: data.user.role || "agronomist",
          farm_id: data.user.farm_id || 1,
          token: data.access_token,
        };
        setUser(session);
        localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(session));
        return { success: true, message: `Добро пожаловать, ${session.full_name}!` };
      } else {
        const err = await res.json().catch(() => ({}));
        return { success: false, message: err.detail || "Неверный логин или пароль." };
      }
    } catch (e: any) {
      console.warn("Cloud login failed", e);
      return {
        success: false,
        message: "Не удалось подключиться к серверу Render. Проверьте интернет или статус сервера.",
      };
    }
  };

  const register = async (payload: {
    username: string;
    email: string;
    password: string;
    full_name: string;
    role: string;
    farm_id: number;
  }) => {
    try {
      const res = await fetch(`${API_BASE}/api/v1/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        // Automatically log in with the new credentials
        return await login(payload.username, payload.password);
      } else {
        const err = await res.json().catch(() => ({}));
        return { success: false, message: err.detail || "Не удалось создать аккаунт." };
      }
    } catch (e: any) {
      console.warn("Cloud registration error", e);
      return {
        success: false,
        message: "Ошибка подключения к серверу. Попробуйте снова.",
      };
    }
  };

  const logout = () => {
    setUser(null);
    try {
      localStorage.removeItem(SESSION_STORAGE_KEY);
    } catch (e) {
      console.warn("Failed to clear user session", e);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthModalOpen,
        authModalTab,
        openAuthModal,
        closeAuthModal,
        setAuthModalTab,
        login,
        register,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
