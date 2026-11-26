"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import { getAllStoredUsers, getCurrentUser, type UserProfile } from "@/lib/auth-storage";
import { getStoredInventory, getStoredBalance, type InventoryItem } from "@/lib/inventory-storage";
import { playClickSound } from "@/lib/sound-fx";

interface LeaderboardPlayer {
  id: string;
  name: string;
  email: string;
  avatar: string;
  rank: string;
  skinsCount: number;
  inventoryValue: number;
  balance: number;
  totalWealth: number;
  startingCapital: number;
  profit: number;
  isCurrentUser: boolean;
  createdAt: number;
}

export default function LeaderboardPage() {
  const [players, setPlayers] = useState<LeaderboardPlayer[]>([]);
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);

  const refreshLeaderboard = () => {
    const rawUsers = getAllStoredUsers();
    const active = getCurrentUser();
    setCurrentUser(active);

    const activeInv = getStoredInventory();
    const activeBal = getStoredBalance();

    const mapped: LeaderboardPlayer[] = rawUsers.map((u) => {
      const isCurrent = active ? active.id === u.id || active.email.toLowerCase() === u.email.toLowerCase() : false;
      const inv: InventoryItem[] = isCurrent ? activeInv : u.inventory || [];
      const bal: number = isCurrent ? activeBal : u.balance || 0;

      const invVal = inv.reduce((sum, s) => sum + (s.price || 0), 0);
      const total = invVal + bal;

      // Визначаємо початковий капітал гравця:
      // sp_user_a: 75 022 GC, sp_user_b: 41 500 GC
      // зареєстрований користувач: u.initialCapital або дефолт 75 000 GC
      const startCap =
        u.initialCapital ??
        (u.id === "sp_user_a" || u.email?.toLowerCase().includes("+a@")
          ? 75022
          : u.id === "sp_user_b" || u.email?.toLowerCase().includes("+b@")
          ? 41500
          : 75000);

      const netProfit = total - startCap;

      return {
        id: u.id,
        name: u.nickname || "Goi Master",
        email: u.email,
        avatar: u.avatar || u.nickname?.substring(0, 2).toUpperCase() || "G",
        rank: u.rank || "Global Elite",
        skinsCount: inv.length,
        inventoryValue: invVal,
        balance: bal,
        totalWealth: total,
        startingCapital: startCap,
        profit: netProfit,
        isCurrentUser: isCurrent,
        createdAt: u.createdAt || Date.now(),
      };
    });

    mapped.sort((a, b) => b.totalWealth - a.totalWealth);
    setPlayers(mapped);
  };

  useEffect(() => {
    let active = true;
    queueMicrotask(() => {
      if (active) refreshLeaderboard();
    });

    const handleAuth = () => refreshLeaderboard();
    const handleInv = () => refreshLeaderboard();
    const handleBal = () => refreshLeaderboard();

    window.addEventListener("goi-auth-updated", handleAuth);
    window.addEventListener("goi-inventory-updated", handleInv);
    window.addEventListener("goi-balance-updated", handleBal);

    return () => {
      active = false;
      window.removeEventListener("goi-auth-updated", handleAuth);
      window.removeEventListener("goi-inventory-updated", handleInv);
      window.removeEventListener("goi-balance-updated", handleBal);
    };
  }, []);

  const totalPlayers = players.length;
  const totalMarketValue = players.reduce((sum, p) => sum + p.totalWealth, 0);
  const totalProfit = players.reduce((sum, p) => sum + p.profit, 0);

  const openAuthModal = () => {
    playClickSound();
    window.dispatchEvent(new CustomEvent("goi-open-auth", { detail: "register" }));
  };

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8 min-h-screen">
      <div className="mb-8 flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="flex size-2.5 rounded-full bg-emerald-400 animate-pulse" />
            <span className="text-[11px] font-bold uppercase tracking-wider text-emerald-400">
              Офіційний рейтинг · Жива синхронізація
            </span>
          </div>
          <h1 className="text-3xl font-black text-white sm:text-4xl">Таблиця лідерів</h1>
          <p className="mt-1 text-sm text-slate-400 max-w-2xl">
            Справжній рейтинг виключно зареєстрованих гравців платформи (включаючи профілі Supabase).
            Ранжування здійснюється за загальним капіталом (вартість інвентаря + баланс GC).
          </p>
        </div>

        <div className="flex flex-wrap gap-4">
          <div className="rounded-2xl border border-white/10 bg-[#0e111a] px-5 py-3 shadow-lg">
            <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Гравців у базі</p>
            <p className="font-mono text-xl font-black text-white mt-0.5">{totalPlayers}</p>
          </div>
          <div className="rounded-2xl border border-white/10 bg-[#0e111a] px-5 py-3 shadow-lg">
            <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Сумарний профіт</p>
            <p className={`font-mono text-xl font-black mt-0.5 ${totalProfit >= 0 ? "text-emerald-400" : "text-rose-400"}`}>
              {totalProfit >= 0 ? `+${formatCoins(totalProfit)}` : `-${formatCoins(Math.abs(totalProfit))}`} GC
            </p>
          </div>
          <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 px-5 py-3 shadow-lg">
            <p className="text-[10px] font-bold uppercase tracking-wider text-emerald-300">Капітал рейтингу</p>
            <p className="font-mono text-xl font-black text-emerald-400 mt-0.5">
              {formatCoins(totalMarketValue)} GC
            </p>
          </div>
        </div>
      </div>

      {!currentUser && (
        <div className="mb-8 rounded-3xl border border-amber-500/30 bg-gradient-to-r from-amber-500/10 via-[#181308] to-transparent p-5 sm:p-6 shadow-xl flex flex-wrap items-center justify-between gap-4 animate-fade-in">
          <div className="flex items-center gap-4">
            <div className="flex size-12 items-center justify-center rounded-2xl bg-amber-500/20 text-2xl">
              🏆
            </div>
            <div>
              <h3 className="text-base font-black text-white">Твій акаунт ще не в рейтингу!</h3>
              <p className="text-xs text-slate-300 mt-0.5">
                Зареєструйся за своєю поштою або увійди, щоб посісти своє заслужене місце серед лідерів GoiCoins!
              </p>
            </div>
          </div>
          <button
            onClick={openAuthModal}
            className="rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 hover:brightness-110 px-6 py-2.5 text-xs font-black text-[#1a1104] shadow-lg shadow-amber-500/20 transition"
          >
            Увійти / Зареєструватися ⚡
          </button>
        </div>
      )}

      <div className="overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0e111a] shadow-2xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/[0.08] bg-white/[0.02] text-[11px] font-bold uppercase tracking-wider text-slate-400">
                <th className="py-4 px-5 text-center w-20">Місце</th>
                <th className="py-4 px-5">Гравець</th>
                <th className="py-4 px-5">Ранг</th>
                <th className="py-4 px-5 text-center">Скінів</th>
                <th className="py-4 px-5 text-right">Вартість інвентаря</th>
                <th className="py-4 px-5 text-right">Профіт / Злив</th>
                <th className="py-4 px-5 text-right">Загальний капітал</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/[0.06] text-sm">
              {players.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-slate-500 text-sm">
                    Немає зареєстрованих гравців у базі даних.
                  </td>
                </tr>
              ) : (
                players.map((p, index) => {
                  const placeNumber = index + 1;
                  const isTop1 = index === 0;
                  const isTop2 = index === 1;
                  const isTop3 = index === 2;

                  const medalBadge = isTop1
                    ? "text-amber-300 bg-amber-400/20 border-amber-400/30 shadow-md shadow-amber-500/10"
                    : isTop2
                    ? "text-slate-200 bg-slate-300/20 border-slate-300/30"
                    : isTop3
                    ? "text-amber-600 bg-amber-700/20 border-amber-700/30"
                    : "text-slate-400 bg-white/5 border-white/5";

                  const medalIcon = isTop1 ? "🥇" : isTop2 ? "🥈" : isTop3 ? "🥉" : null;

                  return (
                    <tr
                      key={p.id}
                      className={`transition duration-150 ${
                        p.isCurrentUser
                          ? "bg-emerald-500/[0.07] hover:bg-emerald-500/[0.12] border-l-4 border-l-emerald-400"
                          : "hover:bg-white/[0.02]"
                      }`}
                    >
                      <td className="py-4 px-5 text-center font-mono font-bold">
                        <span
                          className={`inline-flex items-center justify-center min-w-8 h-8 px-2 rounded-xl border text-xs font-black ${medalBadge}`}
                        >
                          {medalIcon ? `${medalIcon} 0${placeNumber}` : `0${placeNumber}`}
                        </span>
                      </td>

                      <td className="py-4 px-5">
                        <div className="flex items-center gap-3.5">
                          <div className="relative flex size-10 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-teal-600 text-xs font-black text-[#05130d] shadow-md shadow-emerald-500/20">
                            {p.avatar}
                          </div>
                          <div>
                            <div className="flex items-center gap-2">
                              <span className="font-bold text-white text-sm">{p.name}</span>
                              {p.isCurrentUser && (
                                <span className="rounded-full bg-emerald-400/20 px-2 py-0.5 text-[10px] font-black text-emerald-300 border border-emerald-400/30">
                                  Це ти ✨
                                </span>
                              )}
                            </div>
                            <span className="text-[11px] font-mono text-slate-500 block">{p.email}</span>
                          </div>
                        </div>
                      </td>

                      <td className="py-4 px-5">
                        <span className="rounded-lg border border-white/10 bg-white/5 px-3 py-1 text-xs font-bold text-slate-300">
                          {p.rank}
                        </span>
                      </td>

                      <td className="py-4 px-5 text-center font-mono font-bold text-slate-300">
                        {p.skinsCount} шт.
                      </td>

                      <td className="py-4 px-5 text-right font-mono font-bold text-slate-200">
                        {formatCoins(p.inventoryValue)} GC
                      </td>

                      {/* Стовпчик Профіт / Злив */}
                      <td className="py-4 px-5 text-right font-mono font-bold">
                        {p.profit > 0 ? (
                          <span className="inline-flex items-center gap-1 rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-2.5 py-1 text-xs font-black text-emerald-400 shadow-sm shadow-emerald-500/10">
                            +{formatCoins(p.profit)} GC 📈
                          </span>
                        ) : p.profit < 0 ? (
                          <span className="inline-flex items-center gap-1 rounded-xl border border-rose-500/30 bg-rose-500/10 px-2.5 py-1 text-xs font-black text-rose-400 shadow-sm shadow-rose-500/10">
                            -{formatCoins(Math.abs(p.profit))} GC 📉
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 rounded-xl border border-white/5 bg-white/5 px-2.5 py-1 text-xs font-bold text-slate-400">
                            0 GC
                          </span>
                        )}
                      </td>

                      <td className="py-4 px-5 text-right font-mono font-black text-emerald-400 text-base">
                        {formatCoins(p.totalWealth)} GC
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="mt-8 flex flex-wrap items-center justify-between gap-4 text-xs text-slate-500">
        <p>💡 Рейтинг оновлюється автоматично при реєстрації, виграші в апгрейдері або продажі скінів.</p>
        <Link href="/" className="font-bold text-emerald-400 hover:text-emerald-300 transition">
          Перейти до Апгрейдера →
        </Link>
      </div>
    </div>
  );
}
