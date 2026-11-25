"use client";

import { useState, useEffect, useMemo } from "react";
import {
  isAdminAuthenticated,
  verifyAdminPassphrase,
  logoutAdmin,
  isLockedOut,
  isGodModeActive,
  setGodMode,
  getAdminPlayerList,
  grantCoinsToUser,
  grantSkinToUser,
} from "@/lib/admin-vault-storage";
import { clearLiveDrops, addLiveDrop } from "@/lib/live-drops-storage";
import { resetWheelCooldownForTest } from "@/lib/daily-wheel-storage";
import { skins, formatCoins } from "@/app/data";
import { playClickSound, playWinSound, playCoinSound } from "@/lib/sound-fx";
import { triggerConfetti } from "@/lib/confetti";

interface AdminVaultModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function AdminVaultModal({ isOpen, onClose }: AdminVaultModalProps) {
  const [isAuth, setIsAuth] = useState(false);
  const [passphrase, setPassphrase] = useState("");
  const [errorMsg, setErrorMsg] = useState("");
  const [lockoutSec, setLockoutSec] = useState(0);
  const [godMode, setGodModeState] = useState(false);
  const [toastMsg, setToastMsg] = useState("");

  const [players, setPlayers] = useState<{ id: string; nickname: string; email: string; balance: number }[]>([]);
  const [selectedPlayerId, setSelectedPlayerId] = useState<string>("current_session");
  const [customCoins, setCustomCoins] = useState<string>("");

  const [skinSearch, setSkinSearch] = useState<string>("");

  useEffect(() => {
    if (isOpen) {
      setIsAuth(isAdminAuthenticated());
      setGodModeState(isGodModeActive());
      const lock = isLockedOut();
      setLockoutSec(lock.remainingSec);
      setErrorMsg("");
      setPassphrase("");

      const playerList = getAdminPlayerList();
      setPlayers(playerList);
      if (playerList.length > 0) {
        setSelectedPlayerId(playerList[0].id);
      }
    }
  }, [isOpen]);

  const filteredSkins = useMemo(() => {
    const q = skinSearch.toLowerCase().trim();
    if (!q) return skins.slice(0, 30);
    return skins.filter(
      (s) =>
        s.name.toLowerCase().includes(q) ||
        s.weapon.toLowerCase().includes(q) ||
        (s.rarity && s.rarity.toLowerCase().includes(q))
    ).slice(0, 30);
  }, [skinSearch]);

  if (!isOpen) return null;

  const showToast = (msg: string) => {
    setToastMsg(msg);
    setTimeout(() => setToastMsg(""), 3500);
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    playClickSound();

    const lock = isLockedOut();
    if (lock.locked) {
      setErrorMsg(`Блокування активне: зачекайте ${lock.remainingSec}с`);
      return;
    }

    const success = verifyAdminPassphrase(passphrase);
    if (success) {
      setIsAuth(true);
      setErrorMsg("");
      playWinSound();
      triggerConfetti();
      const pList = getAdminPlayerList();
      setPlayers(pList);
    } else {
      const updatedLock = isLockedOut();
      if (updatedLock.locked) {
        setLockoutSec(updatedLock.remainingSec);
        setErrorMsg("⚠️ 3 невдалі спроби! Доступ заблоковано на 10 хвилин.");
      } else {
        setErrorMsg("❌ Невірний майстер-код доступу!");
      }
    }
  };

  const handleLogout = () => {
    playClickSound();
    logoutAdmin();
    setIsAuth(false);
    setGodModeState(false);
    onClose();
  };

  const handleToggleGodMode = () => {
    playClickSound();
    const next = !godMode;
    setGodMode(next);
    setGodModeState(next);
    showToast(next ? "🔥 Бог-Режим УВІМКНЕНО: 100% виграш в рулетці!" : "Бог-Режим вимкнено");
  };

  const handleSendCoins = (amount: number) => {
    playCoinSound();
    const res = grantCoinsToUser(selectedPlayerId, amount);
    if (res.success) {
      showToast(`🪙 Нараховано +${formatCoins(amount)} GC для [${res.targetName}]!`);
      setPlayers(getAdminPlayerList());
    }
  };

  const handleSendCustomCoins = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseInt(customCoins.replace(/\s+/g, ""), 10);
    if (isNaN(val) || val <= 0) return;
    handleSendCoins(val);
    setCustomCoins("");
  };

  const handleSendSkin = (skin: typeof skins[0]) => {
    playWinSound();
    const res = grantSkinToUser(selectedPlayerId, skin);
    if (res.success) {
      showToast(`🎁 Скін ${skin.weapon} | ${skin.name} видано для [${res.targetName}]!`);
    }
  };

  const handleBroadcastDrop = () => {
    playClickSound();
    addLiveDrop({
      playerName: "ADMIN ROOT ⚡",
      playerAvatar: "⚡",
      playerRank: "Developer",
      weapon: "AWP",
      name: "Dragon Lore",
      price: 450000,
      image: "https://community.akamai.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDEVlxkKgpot621FAR17PLfYQJD_9W7m5a0mvLwOq7c2D4B6pcn3-3E99n22Qfn_kFtY2inINfAcVJtNArR-1G5wri-jce0ot2XnjXh2Y2F",
      accent: "#eb4b4b",
      rarity: "Таємне",
      chance: "1.0%",
      multiplier: "×100.0",
    });
    showToast("📡 Тестовий дроп трансльовано в Live-стрічку!");
  };

  const selectedTargetObj = players.find((p) => p.id === selectedPlayerId) || players[0];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-2xl p-4 sm:p-6 animate-fade-in font-mono">
      <div className="relative w-full max-w-4xl max-h-[92vh] overflow-y-auto rounded-3xl border-2 border-cyan-500/50 bg-[#060913] p-6 sm:p-10 shadow-[0_0_100px_rgba(6,182,212,0.3)] text-slate-200">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-5 top-5 flex size-11 items-center justify-center rounded-2xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition text-lg font-bold"
        >
          ✕
        </button>

        <div className="flex items-center gap-3 text-cyan-400 mb-2">
          <span className="size-3.5 rounded-full bg-cyan-400 animate-ping" />
          <span className="text-xs sm:text-sm font-black tracking-widest uppercase">
            ROOT ACCESS // SECURE CONSOLE PRO
          </span>
        </div>
        <h2 className="text-3xl sm:text-4xl font-black text-white tracking-tight">Cyber Admin Vault v4.5</h2>
        <p className="text-sm text-slate-400 mt-1 max-w-2xl">
          Повний контроль над економікою CS2: нарахування монет та видача будь-якого скіна обраному учаснику.
        </p>

        {toastMsg && (
          <div className="my-4 rounded-2xl border border-cyan-400 bg-cyan-500/20 px-5 py-3.5 text-sm font-black text-cyan-200 animate-pulse shadow-lg">
            {toastMsg}
          </div>
        )}

        {!isAuth ? (
          <form onSubmit={handleLogin} className="mt-8 rounded-3xl border border-white/10 bg-white/[0.03] p-8 text-center max-w-xl mx-auto">
            <div className="text-5xl mb-4">🔒</div>
            <p className="text-lg font-black text-white mb-1">Введіть секретний Master-Passphrase</p>
            <p className="text-xs sm:text-sm text-slate-400 mb-6">
              Захист від сканування: доступ мають лише власники приватного ключа розробника.
            </p>

            <input
              type="password"
              required
              value={passphrase}
              onChange={(e) => setPassphrase(e.target.value)}
              placeholder="Введіть код доступу..."
              disabled={lockoutSec > 0}
              className="w-full rounded-2xl border-2 border-cyan-500/40 bg-black/70 px-5 py-4 text-center text-base sm:text-lg text-cyan-300 placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-cyan-400"
            />

            {errorMsg && <p className="mt-3 text-sm text-rose-400 font-bold">{errorMsg}</p>}

            <button
              type="submit"
              disabled={lockoutSec > 0}
              className="w-full mt-6 rounded-2xl bg-gradient-to-r from-cyan-500 to-blue-600 hover:brightness-110 py-4 text-base font-black text-[#041018] shadow-xl shadow-cyan-500/25 transition disabled:opacity-40"
            >
              {lockoutSec > 0 ? `Заблоковано (${lockoutSec}с)` : "РОЗБЛОКУВАТИ КОНСОЛЬ ⚡"}
            </button>
            <p className="text-xs text-slate-500 mt-4">Майстер-код за замовчуванням: GOI-ADMIN-2026</p>
          </form>
        ) : (
          <div className="mt-8 space-y-6">
            {/* Вибір цільового гравця */}
            <div className="rounded-2xl border border-cyan-500/30 bg-cyan-950/20 p-5">
              <div className="flex flex-wrap items-center justify-between gap-4">
                <div>
                  <p className="text-xs sm:text-sm font-black text-cyan-400 uppercase tracking-wider">
                    👤 Оберіть отримувача (Цільовий акаунт):
                  </p>
                  <p className="text-xs text-slate-400 mt-0.5">
                    Усі нарахування монет та скінів нижче будуть передані цьому гравцю.
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <select
                    value={selectedPlayerId}
                    onChange={(e) => setSelectedPlayerId(e.target.value)}
                    className="rounded-xl border border-cyan-500/40 bg-[#0d121f] px-4 py-2.5 text-sm font-black text-cyan-300 focus:outline-none focus:ring-2 focus:ring-cyan-400"
                  >
                    {players.map((p) => (
                      <option key={p.id} value={p.id} className="bg-[#0a0d18] text-white">
                        {p.nickname} {p.email !== "active_session" ? `(${p.email})` : ""}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {selectedTargetObj && (
                <div className="mt-3 pt-3 border-t border-cyan-500/20 flex flex-wrap items-center gap-4 text-xs text-slate-300">
                  <span>
                    Активний одержувач: <strong className="text-white">{selectedTargetObj.nickname}</strong>
                  </span>
                  <span>·</span>
                  <span>
                    Баланс: <strong className="text-emerald-400">{formatCoins(selectedTargetObj.balance)} GC</strong>
                  </span>
                </div>
              )}
            </div>

            {/* Бог-режим */}
            <div className="rounded-2xl border border-amber-500/40 bg-amber-500/10 p-5 flex flex-wrap items-center justify-between gap-4">
              <div>
                <div className="flex items-center gap-2.5">
                  <span className="text-xl">⚡</span>
                  <p className="text-base font-black text-amber-300 uppercase">Бог-Режим (100% Luck in Upgrader)</p>
                </div>
                <p className="text-xs sm:text-sm text-slate-300 mt-1">
                  Рулетка апгрейдера завжди гарантовано виграє для демонстрації безпрограшних серій.
                </p>
              </div>
              <button
                onClick={handleToggleGodMode}
                className={`rounded-2xl px-6 py-3.5 text-sm font-black transition ${
                  godMode
                    ? "bg-amber-400 text-black shadow-xl shadow-amber-400/30 scale-105"
                    : "border-2 border-white/20 bg-black/50 text-slate-400 hover:text-white"
                }`}
              >
                {godMode ? "УВІМКНЕНО 🔥" : "ВИМКНЕНО"}
              </button>
            </div>

            {/* Монетний двір */}
            <div className="rounded-2xl border border-white/10 bg-white/[0.02] p-5 sm:p-6">
              <p className="text-sm font-black text-emerald-400 uppercase tracking-wider mb-3">
                🪙 Монетний двір (Нарахування GoiCoins)
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
                <button
                  onClick={() => handleSendCoins(100000)}
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 py-3.5 px-4 text-sm font-black text-emerald-300 transition hover:scale-105 active:scale-95"
                >
                  +100 000 GC
                </button>
                <button
                  onClick={() => handleSendCoins(1000000)}
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 py-3.5 px-4 text-sm font-black text-emerald-300 transition hover:scale-105 active:scale-95"
                >
                  +1 000 000 GC
                </button>
                <button
                  onClick={() => handleSendCoins(5000000)}
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 py-3.5 px-4 text-sm font-black text-emerald-300 transition hover:scale-105 active:scale-95"
                >
                  +5 000 000 GC
                </button>
                <button
                  onClick={() => handleSendCoins(20000000)}
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 py-3.5 px-4 text-sm font-black text-emerald-300 transition hover:scale-105 active:scale-95 shadow-lg shadow-emerald-500/20"
                >
                  +20 000 000 GC 🔥
                </button>
              </div>

              {/* Власна сума */}
              <form onSubmit={handleSendCustomCoins} className="flex gap-3">
                <input
                  type="number"
                  min="1"
                  value={customCoins}
                  onChange={(e) => setCustomCoins(e.target.value)}
                  placeholder="Введіть довільну кількість GC (напр. 50000)..."
                  className="flex-1 rounded-xl border border-white/15 bg-black/60 px-4 py-3 text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-emerald-400"
                />
                <button
                  type="submit"
                  className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-6 py-3 text-sm font-black text-[#05130d] shadow-md transition"
                >
                  Нарахувати 🪙
                </button>
              </form>
            </div>

            {/* Видача будь-якого скіна */}
            <div className="rounded-2xl border border-white/10 bg-white/[0.02] p-5 sm:p-6">
              <div className="flex flex-wrap items-center justify-between gap-3 mb-3">
                <p className="text-sm font-black text-cyan-400 uppercase tracking-wider">
                  🎁 Видача будь-якого скіна в інвентар
                </p>
                <input
                  type="text"
                  value={skinSearch}
                  onChange={(e) => setSkinSearch(e.target.value)}
                  placeholder="Пошук скіна (AWP, Knife, Howl, Lore...)"
                  className="rounded-xl border border-cyan-500/30 bg-black/60 px-4 py-2 text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-cyan-400 w-full sm:w-64"
                />
              </div>

              <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 gap-3 max-h-60 overflow-y-auto p-1">
                {filteredSkins.map((skin) => (
                  <button
                    key={`${skin.weapon}-${skin.name}`}
                    onClick={() => handleSendSkin(skin)}
                    className="flex flex-col items-center justify-between rounded-xl border border-white/10 bg-black/50 p-2.5 hover:border-cyan-400/60 hover:bg-cyan-500/10 transition group text-center"
                    title={`Видати ${skin.weapon} | ${skin.name}`}
                  >
                    <img src={skin.image} alt={skin.name} className="h-12 object-contain my-1 group-hover:scale-105 transition" />
                    <span className="text-xs font-bold text-white truncate w-full">{skin.name}</span>
                    <span className="text-[10px] text-slate-400">{skin.weapon}</span>
                    <span className="text-[10px] text-emerald-400 font-mono mt-1">+{formatCoins(skin.price)} GC</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Системні утиліти */}
            <div className="rounded-2xl border border-white/10 bg-white/[0.02] p-5 flex flex-wrap items-center justify-between gap-3">
              <button
                onClick={handleBroadcastDrop}
                className="rounded-xl border border-purple-500/40 bg-purple-500/15 hover:bg-purple-500/25 px-4 py-3 text-xs sm:text-sm font-bold text-purple-300"
              >
                📡 Транслювати тестовий дроп
              </button>
              <button
                onClick={() => {
                  playClickSound();
                  resetWheelCooldownForTest();
                  showToast("🎡 Таймер колеса скинуто (для розробника)!");
                }}
                className="rounded-xl border border-amber-500/40 bg-amber-500/15 hover:bg-amber-500/25 px-4 py-3 text-xs sm:text-sm font-bold text-amber-300"
              >
                🎡 Скинути таймер колеса
              </button>
              <button
                onClick={() => {
                  playClickSound();
                  clearLiveDrops();
                  showToast("🧹 Стрічку дропів очищено!");
                }}
                className="rounded-xl border border-rose-500/40 bg-rose-500/15 hover:bg-rose-500/25 px-4 py-3 text-xs sm:text-sm font-bold text-rose-300"
              >
                🧹 Очистити Live-дропи
              </button>
            </div>

            {/* Нижня панель виходу */}
            <div className="pt-4 border-t border-white/10 flex flex-wrap items-center justify-between gap-3">
              <span className="text-xs text-slate-500">Автоматичне завершення сесії при закритті вкладки</span>
              <button
                onClick={handleLogout}
                className="rounded-2xl bg-rose-500/20 border border-rose-500/40 hover:bg-rose-500/30 px-6 py-3 text-sm font-black text-rose-300 transition shadow-lg"
              >
                🔒 ЕКСТРЕНИЙ ВИХІД (LOCKDOWN)
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
