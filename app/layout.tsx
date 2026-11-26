import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import SiteHeader from "./components/site-header";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "GoiCoins Skin Simulator",
  description: "Апгрейд, колекція та крафт скінів у світі GoiCoins.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="uk"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="flex min-h-full flex-col bg-[#090b10] text-slate-100">
        <SiteHeader />
        <main className="flex-1">
          {children}
          <footer className="p-4 text-center text-xs text-gray-500">Версія ПР 7 · 2026</footer>
        </main>
        <footer className="border-t border-white/[0.06]">
          <div className="mx-auto flex max-w-7xl flex-col gap-2 px-5 py-6 text-xs text-slate-600 sm:flex-row sm:items-center sm:justify-between lg:px-8">
            <span>GoiCoins Skin Simulator · навчальний демо-проєкт</span>
            <span>Усі скіни та баланси демонстраційні</span>
          </div>
        </footer>
      </body>
    </html>
  );
}
