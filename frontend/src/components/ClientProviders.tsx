"use client";

import React from "react";
import { AuthProvider } from "@/context/AuthContext";
import AuthModal from "@/components/AuthModal";

export default function ClientProviders({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <AuthProvider>
      {children}
      <AuthModal />
    </AuthProvider>
  );
}
