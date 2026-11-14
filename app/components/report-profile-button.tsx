"use client";

import { useState, type FormEvent } from "react";

export default function ReportProfileButton() {
  const [isOpen, setIsOpen] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  function submitReport(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitted(true);
  }

  return (
    <>
      <button
        type="button"
        onClick={() => {
          setSubmitted(false);
          setIsOpen(true);
        }}
        className="rounded-xl border border-rose-400/20 bg-rose-400/[0.06] px-4 py-2.5 text-sm font-semibold text-rose-200 transition hover:bg-rose-400/10"
      >
        Поскаржитися на профіль
      </button>
      {isOpen && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/75 p-4 backdrop-blur-sm"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) setIsOpen(false);
          }}
        >
          <section
            aria-labelledby="report-title"
            aria-modal="true"
            className="w-full max-w-md rounded-2xl border border-white/10 bg-[#151821] p-6 shadow-2xl shadow-black/60"
            role="dialog"
          >
            <div className="flex items-start justify-between gap-4">
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-rose-300">
                  Безпека спільноти
                </p>
                <h2 id="report-title" className="mt-2 text-xl font-bold text-white">
                  Скарга на профіль
                </h2>
              </div>
              <button
                type="button"
                aria-label="Закрити"
                onClick={() => setIsOpen(false)}
                className="rounded-lg p-2 text-slate-400 transition hover:bg-white/10 hover:text-white"
              >
                ✕
              </button>
            </div>
            {submitted ? (
              <div className="mt-6 rounded-xl border border-amber-300/15 bg-amber-300/[0.06] p-4">
                <p className="font-semibold text-amber-200">Демо-режим</p>
                <p className="mt-1 text-sm leading-6 text-slate-400">
                  Скаргу не надіслано: цей прототип не підключений до служби підтримки.
                </p>
                <button
                  type="button"
                  onClick={() => setIsOpen(false)}
                  className="mt-4 rounded-lg bg-amber-300 px-4 py-2 text-sm font-bold text-[#17120a] hover:bg-amber-200"
                >
                  Зрозуміло
                </button>
              </div>
            ) : (
              <form onSubmit={submitReport} className="mt-5">
                <label htmlFor="report-reason" className="text-sm font-medium text-slate-300">
                  Причина скарги
                </label>
                <select
                  id="report-reason"
                  required
                  defaultValue=""
                  className="mt-2 w-full rounded-xl border border-white/10 bg-[#0c0e14] px-3 py-3 text-sm text-slate-200 outline-none focus:border-amber-300/60"
                >
                  <option value="" disabled>
                    Оберіть причину
                  </option>
                  <option>Образлива поведінка</option>
                  <option>Підозра на шахрайство</option>
                  <option>Неприйнятний вміст</option>
                  <option>Інше</option>
                </select>
                <label htmlFor="report-details" className="mt-4 block text-sm font-medium text-slate-300">
                  Деталі <span className="text-slate-500">(необов’язково)</span>
                </label>
                <textarea
                  id="report-details"
                  rows={3}
                  maxLength={500}
                  placeholder="Коротко опишіть ситуацію"
                  className="mt-2 w-full resize-none rounded-xl border border-white/10 bg-[#0c0e14] px-3 py-3 text-sm text-slate-200 outline-none placeholder:text-slate-600 focus:border-amber-300/60"
                />
                <p className="mt-3 text-xs leading-5 text-slate-500">
                  Форма демонстраційна — повідомлення не буде відправлено.
                </p>
                <button
                  type="submit"
                  className="mt-5 w-full rounded-xl bg-rose-400 px-4 py-3 text-sm font-bold text-[#1b0d12] transition hover:bg-rose-300"
                >
                  Надіслати скаргу
                </button>
              </form>
            )}
          </section>
        </div>
      )}
    </>
  );
}
