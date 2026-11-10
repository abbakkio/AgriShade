import type { Metadata } from "next";
import { Instrument_Sans, Inter } from "next/font/google";
import ClientProviders from "@/components/ClientProviders";
import "./globals.css";

const instrumentSans = Instrument_Sans({
  subsets: ["latin"],
  variable: "--font-instrument",
  display: "swap",
  weight: ["400", "500", "600", "700"],
});

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
  weight: ["300", "400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: "AgriShadeNet — Edge AI Precision Agriculture & Foliar Diagnostics",
  description:
    "AgriShadeNet equips agronomists and smallholder farmers with offline edge AI foliar disease detection, glare-resistant field HUD, and calibrated chemical dosage in 41.6ms.",
  keywords: [
    "Edge AI",
    "Precision Agriculture",
    "Crop Disease Detection",
    "MobileNetV3",
    "Foliar Diagnostics",
    "Kazakhstan Agriculture",
    "WCAG 2.1 AAA",
  ],
  authors: [{ name: "Azat Madiyev" }],
  icons: {
    icon: "/favicon.ico",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${instrumentSans.variable} ${inter.variable} scroll-smooth antialiased`}
    >
      <body className="min-h-screen bg-white text-slate-800 font-sans selection:bg-sage selection:text-pine-950">
        <ClientProviders>{children}</ClientProviders>
      </body>
    </html>
  );
}
