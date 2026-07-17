// ==UserScript==
// @name         Dulban Menu — FrostDrop
// @namespace    https://github.com/dulban/dulban-menu
// @version      1.0.0
// @description  «I cant play fair» — чит-меню для FrostDrop: монеты, удача, спавнер, автоматизация. Автономная версия — всё в одном файле.
// @author       Dulban
// @match        *://*/*FrostDrop*
// @match        file:///*FrostDrop*
// @run-at       document-idle
// @grant        none
// ==/UserScript==

(function () {
  'use strict';
  var css = "/* ============================================================\n   DULBAN MENU — «I cant play fair»\n   White & Black (neo-brutalist) UI для FrostDrop\n   Файл стилей. Хранится на GitHub, подгружается лоадером.\n   ============================================================ */\n\n@import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@600;800;900&family=Montserrat:wght@500;600;700;800;900&family=Montserrat+Alternates:wght@700;800&display=swap');\n\n:root {\n  --dm-black: #0d0d0d;\n  --dm-ink: #1a1a1a;\n  --dm-white: #ffffff;\n  --dm-paper: #f7f6f3;\n  --dm-soft: #8a8a86;\n  --dm-line: #0d0d0d;\n  --dm-line-soft: #e3e2df;\n  --dm-accent: #0d0d0d;\n  --dm-good: #1fa356;\n  --dm-bad: #e5493c;\n  --dm-gold: #d5921b;\n  --dm-r-lg: 18px;\n  --dm-r-md: 12px;\n  --dm-r-sm: 9px;\n  --dm-shadow: 4px 4px 0 var(--dm-black);\n  --dm-shadow-lg: 10px 10px 0 rgba(13, 13, 13, 0.92);\n  --dm-font-body: 'TT Interphases Pro', 'TT Fors', 'Montserrat', system-ui, -apple-system, sans-serif;\n  --dm-font-disp: 'TT Gertika', 'Orbitron', 'Montserrat', sans-serif;\n  --dm-font-alt: 'TT Polls', 'Montserrat Alternates', 'Montserrat', sans-serif;\n  --dm-ease-spring: cubic-bezier(0.22, 1.61, 0.36, 1);\n  --dm-ease-pop: cubic-bezier(0.2, 2, 0.45, 0.95);\n  --dm-z: 2147483000;\n}\n\n/* ---------- корень и сбросы ---------- */\n#dulban-root,\n#dulban-root * ,\n#dulban-root *::before,\n#dulban-root *::after {\n  box-sizing: border-box;\n  margin: 0;\n  padding: 0;\n  -webkit-font-smoothing: antialiased;\n}\n#dulban-root {\n  font-family: var(--dm-font-body);\n  font-size: 14px;\n  line-height: 1.45;\n  color: var(--dm-black);\n  position: fixed;\n  inset: 0;\n  width: 0;\n  height: 0;\n  z-index: var(--dm-z);\n}\n#dulban-root button {\n  font-family: inherit;\n  cursor: pointer;\n  border: none;\n  background: none;\n  color: inherit;\n}\n#dulban-root input,\n#dulban-root select,\n#dulban-root textarea {\n  font-family: inherit;\n  color: inherit;\n}\n#dulban-root svg { display: block; }\n\n/* ============================================================\n   FAB — плавающая кнопка запуска\n   ============================================================ */\n.dm-fab {\n  position: fixed;\n  right: 22px;\n  bottom: 22px;\n  width: 58px;\n  height: 58px;\n  border-radius: 18px;\n  background: var(--dm-white);\n  border: 2px solid var(--dm-black);\n  box-shadow: 5px 5px 0 var(--dm-black);\n  display: flex;\n  align-items: center;\n  justify-content: center;\n  transition: transform 0.25s var(--dm-ease-pop), box-shadow 0.25s var(--dm-ease-pop), opacity 0.2s ease;\n  animation: dm-fab-in 0.6s var(--dm-ease-spring) backwards;\n  z-index: var(--dm-z);\n}\n.dm-fab:hover {\n  transform: translate(-2px, -2px) rotate(-3deg);\n  box-shadow: 8px 8px 0 var(--dm-black);\n}\n.dm-fab:active {\n  transform: translate(3px, 3px);\n  box-shadow: 0 0 0 var(--dm-black);\n}\n.dm-fab svg { width: 30px; height: 30px; color: var(--dm-black); }\n.dm-fab .dm-logo-bolt { animation: dm-bolt-flicker 3.2s ease-in-out infinite; }\n.dm-fab::before,\n.dm-fab::after {\n  content: '';\n  position: absolute;\n  inset: -2px;\n  border-radius: 18px;\n  border: 2px solid var(--dm-black);\n  opacity: 0;\n  pointer-events: none;\n  animation: dm-pulse-ring 2.8s ease-out infinite;\n}\n.dm-fab::after { animation-delay: 1.4s; }\n.dm-fab.dm-hidden {\n  opacity: 0;\n  pointer-events: none;\n  transform: scale(0.6) rotate(20deg);\n}\n@keyframes dm-fab-in {\n  from { transform: translateY(90px) rotate(12deg); opacity: 0; }\n  to   { transform: translateY(0) rotate(0); opacity: 1; }\n}\n@keyframes dm-pulse-ring {\n  0%   { opacity: 0.55; transform: scale(1); }\n  70%  { opacity: 0; transform: scale(1.45); }\n  100% { opacity: 0; transform: scale(1.45); }\n}\n@keyframes dm-bolt-flicker {\n  0%, 100% { opacity: 1; }\n  46% { opacity: 1; }\n  48% { opacity: 0.25; }\n  50% { opacity: 1; }\n  53% { opacity: 0.4; }\n  56% { opacity: 1; }\n}\n\n/* ============================================================\n   ПАНЕЛЬ\n   ============================================================ */\n.dm-panel[hidden] { display: none !important; }\n.dm-panel {\n  position: fixed;\n  top: 64px;\n  right: 24px;\n  width: 404px;\n  max-width: calc(100vw - 24px);\n  max-height: min(660px, calc(100vh - 84px));\n  display: flex;\n  flex-direction: column;\n  background: var(--dm-white);\n  border: 2px solid var(--dm-black);\n  border-radius: var(--dm-r-lg);\n  box-shadow: var(--dm-shadow-lg);\n  overflow: hidden;\n  transform-origin: top right;\n  z-index: var(--dm-z);\n}\n.dm-panel.dm-opening { animation: dm-panel-in 0.5s var(--dm-ease-spring); }\n.dm-panel.dm-closing { animation: dm-panel-out 0.22s ease-in forwards; }\n.dm-panel.dm-collapsed .dm-body { display: none; }\n@keyframes dm-panel-in {\n  0%   { transform: scale(0.88) translateY(-16px); opacity: 0; }\n  100% { transform: scale(1) translateY(0); opacity: 1; }\n}\n@keyframes dm-panel-out {\n  to { transform: scale(0.92) translateY(-10px); opacity: 0; }\n}\n\n/* ---------- шапка ---------- */\n.dm-head {\n  display: flex;\n  align-items: center;\n  gap: 12px;\n  padding: 13px 14px 12px 16px;\n  border-bottom: 2px solid var(--dm-black);\n  background-image: repeating-linear-gradient(-45deg, rgba(13, 13, 13, 0.045) 0 7px, transparent 7px 14px);\n  cursor: grab;\n  user-select: none;\n  position: relative;\n  overflow: hidden;\n}\n.dm-head:active { cursor: grabbing; }\n.dm-head::after {\n  content: '';\n  position: absolute;\n  top: 0;\n  bottom: 0;\n  width: 46%;\n  left: -60%;\n  background: linear-gradient(100deg, transparent, rgba(255, 255, 255, 0.85) 50%, transparent);\n  animation: dm-sheen 5.5s ease-in-out infinite;\n  pointer-events: none;\n}\n@keyframes dm-sheen {\n  0%, 62% { left: -60%; }\n  86%, 100% { left: 120%; }\n}\n\n.dm-logo {\n  width: 44px;\n  height: 44px;\n  flex: 0 0 auto;\n  border-radius: 13px;\n  background: var(--dm-black);\n  color: var(--dm-white);\n  display: flex;\n  align-items: center;\n  justify-content: center;\n  position: relative;\n  box-shadow: 3px 3px 0 rgba(13, 13, 13, 0.28);\n}\n.dm-logo svg { width: 28px; height: 28px; }\n.dm-logo .dm-logo-hex {\n  stroke-dasharray: 130;\n  stroke-dashoffset: 130;\n  animation: dm-draw 1.4s 0.15s ease forwards;\n}\n.dm-logo .dm-logo-bolt {\n  transform-origin: 50% 50%;\n  animation: dm-bolt-pop 0.7s 0.9s var(--dm-ease-spring) backwards, dm-bolt-flicker 4.5s 2s ease-in-out infinite;\n}\n.dm-logo::after {\n  content: '';\n  position: absolute;\n  inset: -7px;\n  border: 2px dashed rgba(13, 13, 13, 0.5);\n  border-radius: 16px;\n  animation: dm-ring-spin 14s linear infinite;\n}\n@keyframes dm-draw { to { stroke-dashoffset: 0; } }\n@keyframes dm-bolt-pop {\n  from { transform: scale(0) rotate(-40deg); }\n  to   { transform: scale(1) rotate(0); }\n}\n@keyframes dm-ring-spin { to { transform: rotate(360deg); } }\n\n.dm-titles { flex: 1; min-width: 0; }\n.dm-title {\n  font-family: var(--dm-font-disp);\n  font-weight: 900;\n  font-size: 17px;\n  letter-spacing: 0.14em;\n  line-height: 1.1;\n  white-space: nowrap;\n}\n.dm-title span { color: var(--dm-accent); }\n.dm-cry {\n  margin-top: 3px;\n  font-family: var(--dm-font-alt);\n  font-weight: 800;\n  font-size: 9.5px;\n  letter-spacing: 0.34em;\n  text-transform: uppercase;\n  background: linear-gradient(90deg, #6f6f6a 0%, #0d0d0d 35%, #6f6f6a 70%);\n  background-size: 200% 100%;\n  -webkit-background-clip: text;\n  background-clip: text;\n  color: transparent;\n  animation: dm-cry-shimmer 4s linear infinite;\n  white-space: nowrap;\n}\n@keyframes dm-cry-shimmer {\n  from { background-position: 120% 0; }\n  to   { background-position: -80% 0; }\n}\n\n.dm-head-btns { display: flex; gap: 7px; }\n.dm-hbtn {\n  width: 28px;\n  height: 28px;\n  border: 2px solid var(--dm-black);\n  border-radius: 9px;\n  background: var(--dm-white);\n  display: flex;\n  align-items: center;\n  justify-content: center;\n  transition: transform 0.18s var(--dm-ease-pop), background 0.18s, color 0.18s;\n}\n.dm-hbtn svg { width: 13px; height: 13px; }\n.dm-hbtn:hover { background: var(--dm-black); color: var(--dm-white); transform: translateY(-2px); }\n.dm-hbtn:active { transform: translateY(1px) scale(0.94); }\n\n/* ---------- корпус: рейка вкладок + контент ---------- */\n.dm-body {\n  display: flex;\n  flex: 1;\n  min-height: 0;\n}\n.dm-rail {\n  width: 58px;\n  flex: 0 0 auto;\n  border-right: 2px solid var(--dm-black);\n  background: var(--dm-paper);\n  display: flex;\n  flex-direction: column;\n  align-items: center;\n  padding: 12px 0;\n  gap: 8px;\n}\n.dm-tabbtn {\n  width: 40px;\n  height: 40px;\n  border-radius: 12px;\n  border: 2px solid transparent;\n  display: flex;\n  align-items: center;\n  justify-content: center;\n  color: #6d6d68;\n  position: relative;\n  transition: transform 0.22s var(--dm-ease-pop), background 0.22s, color 0.22s, border-color 0.22s, box-shadow 0.22s;\n}\n.dm-tabbtn svg { width: 19px; height: 19px; }\n.dm-tabbtn:hover {\n  color: var(--dm-black);\n  border-color: var(--dm-black);\n  transform: translateX(2px);\n  background: var(--dm-white);\n}\n.dm-tabbtn.active {\n  background: var(--dm-black);\n  color: var(--dm-white);\n  border-color: var(--dm-black);\n  box-shadow: 3px 3px 0 rgba(13, 13, 13, 0.25);\n  transform: translateX(3px);\n}\n.dm-tabbtn.active::before {\n  content: '';\n  position: absolute;\n  left: -12px;\n  top: 50%;\n  width: 5px;\n  height: 22px;\n  border-radius: 3px;\n  background: var(--dm-black);\n  transform: translateY(-50%);\n  animation: dm-indicator 0.35s var(--dm-ease-spring);\n}\n@keyframes dm-indicator {\n  from { height: 0; opacity: 0; }\n  to   { height: 22px; opacity: 1; }\n}\n/* всплывающая подпись вкладки */\n.dm-tabbtn::after {\n  content: attr(data-tip);\n  position: absolute;\n  left: 52px;\n  top: 50%;\n  transform: translateY(-50%) translateX(-6px);\n  background: var(--dm-black);\n  color: var(--dm-white);\n  font-size: 10.5px;\n  font-weight: 700;\n  letter-spacing: 0.08em;\n  padding: 4px 9px;\n  border-radius: 7px;\n  white-space: nowrap;\n  opacity: 0;\n  pointer-events: none;\n  transition: opacity 0.18s ease, transform 0.22s var(--dm-ease-pop);\n  z-index: 5;\n}\n.dm-tabbtn:hover::after { opacity: 1; transform: translateY(-50%) translateX(0); }\n\n.dm-content {\n  flex: 1;\n  min-width: 0;\n  overflow-y: auto;\n  overflow-x: hidden;\n  padding: 15px 16px 18px;\n  scrollbar-width: thin;\n  scrollbar-color: var(--dm-black) transparent;\n}\n.dm-content::-webkit-scrollbar { width: 9px; }\n.dm-content::-webkit-scrollbar-thumb {\n  background: var(--dm-black);\n  border-radius: 5px;\n  border: 2px solid var(--dm-white);\n}\n\n/* ---------- вкладки и стаггер-анимация ---------- */\n.dm-tab { display: none; }\n.dm-tab.active { display: block; }\n.dm-tab.active > * {\n  animation: dm-rise 0.4s var(--dm-ease-spring) backwards;\n}\n.dm-tab.active > *:nth-child(1) { animation-delay: 0.02s; }\n.dm-tab.active > *:nth-child(2) { animation-delay: 0.06s; }\n.dm-tab.active > *:nth-child(3) { animation-delay: 0.1s; }\n.dm-tab.active > *:nth-child(4) { animation-delay: 0.14s; }\n.dm-tab.active > *:nth-child(5) { animation-delay: 0.18s; }\n.dm-tab.active > *:nth-child(6) { animation-delay: 0.22s; }\n.dm-tab.active > *:nth-child(7) { animation-delay: 0.26s; }\n.dm-tab.active > *:nth-child(8) { animation-delay: 0.3s; }\n@keyframes dm-rise {\n  from { transform: translateY(14px); opacity: 0; }\n  to   { transform: translateY(0); opacity: 1; }\n}\n\n/* ---------- заголовки секций ---------- */\n.dm-sec {\n  display: flex;\n  align-items: center;\n  gap: 8px;\n  margin: 16px 0 9px;\n  font-size: 10.5px;\n  font-weight: 800;\n  letter-spacing: 0.22em;\n  text-transform: uppercase;\n  color: var(--dm-soft);\n}\n.dm-sec:first-child { margin-top: 0; }\n.dm-sec svg { width: 13px; height: 13px; color: var(--dm-black); }\n.dm-sec::after {\n  content: '';\n  flex: 1;\n  height: 2px;\n  background: repeating-linear-gradient(90deg, var(--dm-line-soft) 0 6px, transparent 6px 11px);\n}\n\n/* ---------- карточки ---------- */\n.dm-card {\n  border: 2px solid var(--dm-black);\n  border-radius: var(--dm-r-md);\n  background: var(--dm-white);\n  box-shadow: var(--dm-shadow);\n  padding: 11px 12px;\n  margin-bottom: 11px;\n  transition: transform 0.2s var(--dm-ease-pop), box-shadow 0.2s var(--dm-ease-pop);\n}\n.dm-card:hover {\n  transform: translate(-1px, -1px);\n  box-shadow: 5px 5px 0 var(--dm-black);\n}\n.dm-card.dm-flat { box-shadow: none; }\n.dm-card.dm-flat:hover { transform: none; }\n\n/* ---------- строки настроек ---------- */\n.dm-row {\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 12px;\n  padding: 7px 0;\n}\n.dm-row + .dm-row { border-top: 1.5px dashed var(--dm-line-soft); }\n.dm-row-txt { flex: 1; min-width: 0; }\n.dm-row-title {\n  font-weight: 800;\n  font-size: 13px;\n  display: flex;\n  align-items: center;\n  gap: 7px;\n}\n.dm-row-title svg { width: 15px; height: 15px; flex: 0 0 auto; }\n.dm-row-sub {\n  font-size: 11px;\n  color: var(--dm-soft);\n  margin-top: 2px;\n  font-weight: 600;\n}\n\n/* ---------- тумблер ---------- */\n.dm-toggle {\n  position: relative;\n  width: 48px;\n  height: 26px;\n  flex: 0 0 auto;\n  border: 2px solid var(--dm-black);\n  border-radius: 999px;\n  background: var(--dm-white);\n  transition: background 0.3s ease;\n  overflow: hidden;\n}\n.dm-toggle::before {\n  content: '';\n  position: absolute;\n  top: 2px;\n  left: 2px;\n  width: 18px;\n  height: 18px;\n  border-radius: 999px;\n  background: var(--dm-black);\n  transition: transform 0.35s var(--dm-ease-pop), background 0.3s ease, width 0.2s ease;\n}\n.dm-toggle:active::before { width: 24px; }\n.dm-toggle[aria-pressed='true'] { background: var(--dm-black); }\n.dm-toggle[aria-pressed='true']::before {\n  transform: translateX(22px);\n  background: var(--dm-white);\n}\n.dm-toggle:active[aria-pressed='true']::before { transform: translateX(16px); }\n.dm-toggle::after {\n  content: '';\n  position: absolute;\n  top: 50%;\n  left: 7px;\n  width: 6px;\n  height: 2px;\n  background: rgba(13, 13, 13, 0.35);\n  transform: translateY(-50%);\n  transition: opacity 0.2s;\n}\n.dm-toggle[aria-pressed='true']::after { opacity: 0; }\n\n/* ---------- кнопки ---------- */\n.dm-btn {\n  display: inline-flex;\n  align-items: center;\n  justify-content: center;\n  gap: 7px;\n  border: 2px solid var(--dm-black);\n  border-radius: var(--dm-r-sm);\n  background: var(--dm-white);\n  color: var(--dm-black);\n  font-weight: 800;\n  font-size: 12.5px;\n  padding: 8px 13px;\n  box-shadow: 3px 3px 0 var(--dm-black);\n  transition: transform 0.16s var(--dm-ease-pop), box-shadow 0.16s var(--dm-ease-pop), background 0.16s, color 0.16s;\n  position: relative;\n  overflow: hidden;\n}\n.dm-btn svg { width: 14px; height: 14px; }\n.dm-btn:hover { transform: translate(-2px, -2px); box-shadow: 5px 5px 0 var(--dm-black); }\n.dm-btn:active { transform: translate(2px, 2px); box-shadow: 0 0 0 var(--dm-black); }\n.dm-btn.dm-primary { background: var(--dm-black); color: var(--dm-white); }\n.dm-btn.dm-primary:hover { background: var(--dm-ink); }\n.dm-btn.dm-danger { color: var(--dm-bad); border-color: var(--dm-bad); box-shadow: 3px 3px 0 var(--dm-bad); }\n.dm-btn.dm-danger:hover { box-shadow: 5px 5px 0 var(--dm-bad); }\n.dm-btn.dm-danger:active { box-shadow: 0 0 0 var(--dm-bad); }\n.dm-btn.dm-good { color: var(--dm-good); border-color: var(--dm-good); box-shadow: 3px 3px 0 var(--dm-good); }\n.dm-btn.dm-good:hover { box-shadow: 5px 5px 0 var(--dm-good); }\n.dm-btn.dm-good:active { box-shadow: 0 0 0 var(--dm-good); }\n.dm-btn.dm-block { width: 100%; }\n.dm-btn:disabled { opacity: 0.45; pointer-events: none; }\n/* чернильная волна при клике */\n.dm-ink-dot {\n  position: absolute;\n  border-radius: 50%;\n  background: currentColor;\n  opacity: 0.25;\n  transform: scale(0);\n  animation: dm-ink 0.55s ease-out forwards;\n  pointer-events: none;\n}\n@keyframes dm-ink {\n  to { transform: scale(3.2); opacity: 0; }\n}\n\n.dm-btnrow {\n  display: flex;\n  gap: 8px;\n  flex-wrap: wrap;\n  margin-bottom: 11px;\n}\n.dm-btnrow .dm-btn { flex: 1; min-width: 0; }\n\n/* ---------- чипы ---------- */\n.dm-chips { display: flex; flex-wrap: wrap; gap: 7px; }\n.dm-chip {\n  border: 2px solid var(--dm-black);\n  border-radius: 999px;\n  padding: 5px 12px;\n  font-size: 11.5px;\n  font-weight: 800;\n  background: var(--dm-white);\n  transition: transform 0.15s var(--dm-ease-pop), background 0.15s, color 0.15s, box-shadow 0.15s;\n}\n.dm-chip:hover { transform: translateY(-2px); box-shadow: 0 3px 0 var(--dm-black); }\n.dm-chip:active { transform: translateY(1px) scale(0.95); box-shadow: none; }\n.dm-chip.active { background: var(--dm-black); color: var(--dm-white); }\n\n/* ---------- слайдер ---------- */\n.dm-slider-wrap { display: flex; align-items: center; gap: 11px; padding: 4px 0 2px; }\n.dm-slider { flex: 1; -webkit-appearance: none; appearance: none; height: 26px; background: transparent; }\n.dm-slider::-webkit-slider-runnable-track {\n  height: 4px;\n  border-radius: 2px;\n  background: var(--dm-black);\n}\n.dm-slider::-webkit-slider-thumb {\n  -webkit-appearance: none;\n  width: 20px;\n  height: 20px;\n  margin-top: -8px;\n  border-radius: 7px;\n  border: 2px solid var(--dm-black);\n  background: var(--dm-white);\n  box-shadow: 2px 2px 0 var(--dm-black);\n  transition: transform 0.15s var(--dm-ease-pop);\n}\n.dm-slider::-webkit-slider-thumb:hover { transform: scale(1.15) rotate(8deg); }\n.dm-slider::-moz-range-track { height: 4px; border-radius: 2px; background: var(--dm-black); }\n.dm-slider::-moz-range-thumb {\n  width: 16px;\n  height: 16px;\n  border-radius: 6px;\n  border: 2px solid var(--dm-black);\n  background: var(--dm-white);\n  box-shadow: 2px 2px 0 var(--dm-black);\n}\n.dm-slider-val {\n  min-width: 52px;\n  text-align: center;\n  font-family: var(--dm-font-disp);\n  font-weight: 800;\n  font-size: 13px;\n  border: 2px solid var(--dm-black);\n  border-radius: 8px;\n  padding: 3px 6px;\n  background: var(--dm-paper);\n}\n\n/* ---------- поля ввода ---------- */\n.dm-input, .dm-select, .dm-textarea {\n  width: 100%;\n  border: 2px solid var(--dm-black);\n  border-radius: var(--dm-r-sm);\n  background: var(--dm-white);\n  padding: 8px 11px;\n  font-size: 13px;\n  font-weight: 700;\n  outline: none;\n  transition: box-shadow 0.18s var(--dm-ease-pop), transform 0.18s var(--dm-ease-pop);\n}\n.dm-input:focus, .dm-select:focus, .dm-textarea:focus {\n  box-shadow: 3px 3px 0 var(--dm-accent);\n  transform: translate(-1px, -1px);\n}\n.dm-select {\n  appearance: none;\n  background-image: url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%230d0d0d' stroke-width='3'><path d='m6 9 6 6 6-6'/></svg>\");\n  background-repeat: no-repeat;\n  background-position: right 10px center;\n  padding-right: 30px;\n}\n.dm-textarea {\n  font-family: 'Consolas', 'Menlo', monospace;\n  font-size: 11px;\n  font-weight: 500;\n  min-height: 130px;\n  resize: vertical;\n  white-space: pre;\n}\n.dm-field { margin-bottom: 10px; }\n.dm-label {\n  display: block;\n  font-size: 10.5px;\n  font-weight: 800;\n  letter-spacing: 0.12em;\n  text-transform: uppercase;\n  color: var(--dm-soft);\n  margin-bottom: 5px;\n}\n.dm-inline { display: flex; gap: 8px; }\n.dm-inline .dm-input { flex: 1; }\n\n/* ---------- статистика (дашборд) ---------- */\n.dm-stats {\n  display: grid;\n  grid-template-columns: 1fr 1fr;\n  gap: 9px;\n  margin-bottom: 12px;\n}\n.dm-stat {\n  border: 2px solid var(--dm-black);\n  border-radius: var(--dm-r-md);\n  padding: 10px 11px 9px;\n  background: var(--dm-white);\n  box-shadow: 3px 3px 0 var(--dm-black);\n  transition: transform 0.2s var(--dm-ease-pop), box-shadow 0.2s var(--dm-ease-pop);\n  position: relative;\n  overflow: hidden;\n}\n.dm-stat:hover { transform: translate(-1px, -2px); box-shadow: 4px 5px 0 var(--dm-black); }\n.dm-stat.dm-wide { grid-column: span 2; }\n.dm-stat-k {\n  font-size: 9.5px;\n  font-weight: 800;\n  letter-spacing: 0.16em;\n  text-transform: uppercase;\n  color: var(--dm-soft);\n  display: flex;\n  align-items: center;\n  gap: 5px;\n}\n.dm-stat-k svg { width: 12px; height: 12px; color: var(--dm-black); }\n.dm-stat-v {\n  font-family: var(--dm-font-disp);\n  font-weight: 800;\n  font-size: 20px;\n  margin-top: 3px;\n  font-variant-numeric: tabular-nums;\n  transition: color 0.3s;\n}\n.dm-stat-v.dm-bump { animation: dm-bump 0.45s var(--dm-ease-spring); color: var(--dm-good); }\n@keyframes dm-bump {\n  0% { transform: scale(1); }\n  40% { transform: scale(1.12); }\n  100% { transform: scale(1); }\n}\n\n/* ---------- бейдж активных читов ---------- */\n.dm-badge {\n  display: inline-flex;\n  align-items: center;\n  gap: 6px;\n  border: 2px solid var(--dm-black);\n  background: var(--dm-black);\n  color: var(--dm-white);\n  border-radius: 999px;\n  font-size: 10.5px;\n  font-weight: 800;\n  letter-spacing: 0.1em;\n  padding: 4px 11px;\n  text-transform: uppercase;\n}\n.dm-badge svg { width: 11px; height: 11px; }\n.dm-badge .dm-dot {\n  width: 7px;\n  height: 7px;\n  border-radius: 50%;\n  background: var(--dm-good);\n  animation: dm-blink 1.6s ease-in-out infinite;\n}\n@keyframes dm-blink {\n  0%, 100% { opacity: 1; transform: scale(1); }\n  50% { opacity: 0.35; transform: scale(0.75); }\n}\n\n/* ---------- спавнер: превью ---------- */\n.dm-preview {\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 10px;\n  border: 2px solid var(--dm-black);\n  border-radius: var(--dm-r-md);\n  background: var(--dm-paper);\n  padding: 10px 12px;\n  margin-bottom: 10px;\n}\n.dm-preview-name { font-weight: 800; font-size: 13px; word-break: break-word; }\n.dm-preview-tags { display: flex; gap: 5px; flex-wrap: wrap; margin-top: 4px; }\n.dm-tag {\n  font-size: 9.5px;\n  font-weight: 800;\n  letter-spacing: 0.08em;\n  text-transform: uppercase;\n  border: 1.5px solid var(--dm-black);\n  border-radius: 5px;\n  padding: 2px 6px;\n  background: var(--dm-white);\n}\n.dm-preview-val {\n  font-family: var(--dm-font-disp);\n  font-weight: 800;\n  font-size: 19px;\n  white-space: nowrap;\n}\n.dm-preview-val small { font-size: 10px; color: var(--dm-soft); display: block; text-align: right; }\n\n.dm-mutbox {\n  max-height: 118px;\n  overflow-y: auto;\n  border: 2px solid var(--dm-black);\n  border-radius: var(--dm-r-sm);\n  padding: 8px;\n  display: flex;\n  flex-wrap: wrap;\n  gap: 6px;\n  background: var(--dm-white);\n  scrollbar-width: thin;\n}\n.dm-mutbox .dm-chip { padding: 3px 9px; font-size: 10.5px; border-width: 1.5px; }\n\n/* ---------- подсказка / примечание ---------- */\n.dm-note {\n  display: flex;\n  gap: 8px;\n  align-items: flex-start;\n  border: 2px dashed rgba(13, 13, 13, 0.35);\n  border-radius: var(--dm-r-sm);\n  padding: 8px 10px;\n  font-size: 11px;\n  font-weight: 600;\n  color: #55554f;\n  background: var(--dm-paper);\n  margin-bottom: 11px;\n}\n.dm-note svg { width: 14px; height: 14px; flex: 0 0 auto; margin-top: 1px; }\n\n/* ---------- футер панели ---------- */\n.dm-foot {\n  border-top: 2px solid var(--dm-black);\n  padding: 8px 14px;\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  font-size: 10px;\n  font-weight: 800;\n  letter-spacing: 0.14em;\n  text-transform: uppercase;\n  color: var(--dm-soft);\n  background: var(--dm-paper);\n}\n.dm-foot kbd {\n  font-family: inherit;\n  border: 1.5px solid var(--dm-black);\n  border-bottom-width: 3px;\n  border-radius: 5px;\n  padding: 1px 6px;\n  color: var(--dm-black);\n  background: var(--dm-white);\n}\n\n/* ============================================================\n   ТОСТЫ\n   ============================================================ */\n.dm-toasts {\n  position: fixed;\n  left: 22px;\n  bottom: 22px;\n  display: flex;\n  flex-direction: column;\n  gap: 9px;\n  z-index: var(--dm-z);\n  pointer-events: none;\n}\n.dm-toast {\n  display: flex;\n  align-items: center;\n  gap: 9px;\n  min-width: 210px;\n  max-width: 320px;\n  background: var(--dm-white);\n  border: 2px solid var(--dm-black);\n  border-radius: var(--dm-r-md);\n  box-shadow: 5px 5px 0 var(--dm-black);\n  padding: 10px 13px;\n  font-size: 12.5px;\n  font-weight: 800;\n  position: relative;\n  overflow: hidden;\n  animation: dm-toast-in 0.45s var(--dm-ease-spring);\n}\n.dm-toast.dm-out { animation: dm-toast-out 0.3s ease-in forwards; }\n.dm-toast svg { width: 16px; height: 16px; flex: 0 0 auto; }\n.dm-toast.good svg { color: var(--dm-good); }\n.dm-toast.bad svg { color: var(--dm-bad); }\n.dm-toast.gold svg { color: var(--dm-gold); }\n.dm-toast::after {\n  content: '';\n  position: absolute;\n  left: 0;\n  bottom: 0;\n  height: 3px;\n  width: 100%;\n  background: var(--dm-black);\n  transform-origin: left;\n  animation: dm-toast-bar 2.6s linear forwards;\n}\n@keyframes dm-toast-in {\n  from { transform: translateX(-120%) rotate(-3deg); opacity: 0; }\n  to   { transform: translateX(0) rotate(0); opacity: 1; }\n}\n@keyframes dm-toast-out {\n  to { transform: translateX(-30px) scale(0.9); opacity: 0; }\n}\n@keyframes dm-toast-bar { to { transform: scaleX(0); } }\n\n/* ============================================================\n   ЭФФЕКТЫ ВНУТРИ ИГРЫ (вне #dulban-root)\n   ============================================================ */\n/* рентген стаканчиков: подсветка выигрышного */\n.dm-cup-xray {\n  outline: 3px dashed var(--dm-good, #1fa356);\n  outline-offset: 5px;\n  border-radius: 14px;\n  animation: dm-xray-pulse 1.1s ease-in-out infinite;\n  position: relative;\n}\n@keyframes dm-xray-pulse {\n  0%, 100% { outline-offset: 5px; }\n  50% { outline-offset: 9px; }\n}\n\n/* ============================================================\n   АДАПТИВ + ДОСТУПНОСТЬ\n   ============================================================ */\n@media (max-width: 460px) {\n  .dm-panel {\n    right: 8px;\n    left: 8px;\n    width: auto;\n    top: 12px;\n    max-height: calc(100vh - 24px);\n  }\n  .dm-stats { grid-template-columns: 1fr 1fr; }\n}\n#dulban-root button:focus-visible,\n#dulban-root input:focus-visible,\n#dulban-root select:focus-visible,\n#dulban-root textarea:focus-visible {\n  outline: 3px solid var(--dm-accent);\n  outline-offset: 2px;\n}\n@media (prefers-reduced-motion: reduce) {\n  #dulban-root *, #dulban-root *::before, #dulban-root *::after {\n    animation-duration: 0.01ms !important;\n    animation-iteration-count: 1 !important;\n    transition-duration: 0.01ms !important;\n  }\n}\n";
  var st = document.createElement('style');
  st.id = 'dulban-style';
  st.textContent = css;
  (document.head || document.documentElement).appendChild(st);
})();

/* ============================================================
   DULBAN MENU v1.0.0 — «I cant play fair»
   Чит-меню для FrostDrop.
   Файл логики. Хранится на GitHub, подгружается лоадером
   (Tampermonkey) или расширением Firefox.

   Важно: в игре S / CASES / activeCase объявлены через let/const
   и НЕ видны как window.S и т.п. Поэтому живые ссылки на них
   добываются через глобальные функции игры (save/wpick/…).
   ============================================================ */
(function () {
  'use strict';
  if (window.__DULBAN__) return; // защита от двойной загрузки

  var VERSION = '1.0.0';
  var LS_KEY = 'dulban_menu_v1';

  /* ---------- живые ссылки на данные игры ---------- */
  var FD = { S: null, CASES: [], TRACKS: [], RARITIES: [], MUTATIONS: [], ready: false };
  var G = {}; // оригинальные функции игры
  var nerfDepth = 0; // >0 => makeInstance генерирует мусор (для слабого ИИ в баттлах)

  /* ---------- состояние читов (сохраняется) ---------- */
  var state = {
    freeSpend: false,   // бесконечные монеты (покупки бесплатны)
    uncap: true,        // снять лимит 100 кейсов на MAX
    luckMult: 1,        // множитель удачи на все дропы
    caseLuck: 0,        // 0 = выкл, иначе удача всех кейсов
    minRarity: '',      // гарантированная мин. редкость
    mutAlways: false,   // мутация на каждом дропе
    hotAlways: false,   // hot-джекпот на каждом дропе
    upgWin: false,      // апгрейд всегда успешен
    cupsXray: false,    // подсветка выигрышного стаканчика
    cupsAuto: false,    // всегда угадывать стаканчик
    batWeak: false,     // слабый соперник в баттлах
    autoOpen: false,    // авто-открытие кейсов
    autoOpenMs: 2500,
    autoSell: 0,        // автопродажа дропов дешевле N (0 = выкл)
    autoClaim: false,   // авто-сбор баттлпасса
    tab: 'dash',
    pos: null
  };

  /* ---------- runtime (не сохраняется) ---------- */
  var rt = {
    activeCaseId: null, caseMult: 1, cupsWin: null,
    autoTimer: null, claimTimer: null, statTimer: null,
    sellQueue: [], sellTimer: null, caseLuckOrig: null,
    spTrack: '', spRarity: '', spMuts: [], spSearch: '',
    autoOpened: 0, panelOpen: false
  };

  /* ============================================================
     УТИЛИТЫ
     ============================================================ */
  function num(n) { try { return Math.round(n).toLocaleString('ru-RU'); } catch (e) { return String(n); } }
  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  function clampInt(v, a, b, dflt) {
    v = parseInt(v, 10);
    if (isNaN(v)) return dflt;
    return Math.max(a, Math.min(b, v));
  }
  function persist() {
    try {
      var copy = {};
      for (var k in state) copy[k] = state[k];
      localStorage.setItem(LS_KEY, JSON.stringify(copy));
    } catch (e) { /* ignore */ }
  }
  function restore() {
    try {
      var d = JSON.parse(localStorage.getItem(LS_KEY));
      if (d && typeof d === 'object') {
        for (var k in state) if (k in d) state[k] = d[k];
      }
    } catch (e) { /* ignore */ }
  }

  /* ============================================================
     SVG-ИКОНКИ (без эмодзи)
     ============================================================ */
  function svg(paths, extra) {
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ' + (extra || '') + '>' + paths + '</svg>';
  }
  var I = {
    logo: '<svg viewBox="0 0 48 48" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linejoin="round"><path class="dm-logo-hex" d="M24 4 41 14v20L24 44 7 34V14Z"/><path class="dm-logo-bolt" d="M27 11 16 27h6.4L19 37l12-16h-7.2z" fill="currentColor" stroke="none"/></svg>',
    dash: svg('<rect x="3" y="3" width="7.5" height="7.5" rx="1.5"/><rect x="13.5" y="3" width="7.5" height="7.5" rx="1.5"/><rect x="3" y="13.5" width="7.5" height="7.5" rx="1.5"/><rect x="13.5" y="13.5" width="7.5" height="7.5" rx="1.5"/>'),
    coin: svg('<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4.5"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3"/>'),
    box: svg('<path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="M3 8l9 5 9-5M12 13v8"/>'),
    wand: svg('<path d="M5 19 17 7"/><path d="m17 4 1 2 2 1-2 1-1 2-1-2-2-1 2-1zM6 5l.7 1.4L8 7l-1.3.6L6 9l-.7-1.4L4 7l1.3-.6zM19 14l.7 1.4 1.3.6-1.3.6-.7 1.4-.7-1.4-1.3-.6 1.3-.6z"/>'),
    pad: svg('<path d="M6 9h4M8 7v4"/><circle cx="16" cy="9" r="1" fill="currentColor"/><circle cx="18.5" cy="11.5" r="1" fill="currentColor"/><path d="M17.3 5H6.7a4.7 4.7 0 0 0-4.6 5.5l.9 5.2a2.7 2.7 0 0 0 4.8 1.2L9.5 15h5l1.7 1.9a2.7 2.7 0 0 0 4.8-1.2l.9-5.2A4.7 4.7 0 0 0 17.3 5Z"/>'),
    bot: svg('<rect x="4" y="8" width="16" height="11" rx="3"/><path d="M12 8V4M9 4h6"/><circle cx="9" cy="13" r="1.2" fill="currentColor"/><circle cx="15" cy="13" r="1.2" fill="currentColor"/><path d="M9 16.5h6"/>'),
    wrench: svg('<path d="M14.7 6.3a4.5 4.5 0 0 0-6 5.6L3 17.6V21h3.4l5.7-5.7a4.5 4.5 0 0 0 5.6-6L14.6 12l-2.6-2.6z"/>'),
    x: svg('<path d="M5 5l14 14M19 5 5 19"/>'),
    minus: svg('<path d="M5 12h14"/>'),
    check: svg('<path d="m4 12.5 5.5 5.5L20 6.5"/>'),
    info: svg('<circle cx="12" cy="12" r="9"/><path d="M12 11v5"/><circle cx="12" cy="8" r="0.6" fill="currentColor"/>'),
    zap: svg('<path d="M13 2 4 14h6l-1 8 9-12h-6z"/>'),
    clover: svg('<path d="M12 12c-3.5-.5-5-2-5-4a3 3 0 0 1 5-2 3 3 0 0 1 5 2c0 2-1.5 3.5-5 4Z"/><path d="M12 12c-.5 3.5-2 5-4 5a3 3 0 0 1-2-5 3 3 0 0 1 2-5"/><path d="M12 12c3.5.5 5 2 5 4a3 3 0 0 1-5 2 3 3 0 0 1-5-2"/><path d="M12 12v9"/>'),
    fire: svg('<path d="M12 22c4 0 7-2.7 7-7 0-3-2-5.5-4-7.5C14.5 9 14 10 13 10c0-3-1-6-4-8 .5 3-1 4.5-2.5 6.5S4 12.5 4 15c0 4.3 4 7 8 7Z"/><path d="M12 22c-2 0-3.5-1.5-3.5-3.5S10 15 12 13.5c2 1.5 3.5 3 3.5 5S14 22 12 22Z"/>'),
    gem: svg('<path d="M6 3h12l4 6-10 12L2 9z"/><path d="M2 9h20M9 3l3 6 3-6M12 21 9 9M12 21l3-12"/>'),
    eye: svg('<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>'),
    target: svg('<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.2" fill="currentColor"/>'),
    trash: svg('<path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13M10 11v5M14 11v5"/>'),
    dl: svg('<path d="M12 3v11M7 10l5 5 5-5M4 20h16"/>'),
    ul: svg('<path d="M12 14V3M7 7l5-5 5 5M4 20h16"/>'),
    rocket: svg('<path d="M12 15c-2 0-3-1-3-3 0-4 2-8 3-9 1 1 3 5 3 9 0 2-1 3-3 3Z"/><path d="M9 12c-2 .5-4 2-4 5 2 0 3.5-.5 4.5-1.5M15 12c2 .5 4 2 4 5-2 0-3.5-.5-4.5-1.5"/><path d="M10 18c0 2-1 3-2 4M14 18c0 2 1 3 2 4M12 17v5"/><circle cx="12" cy="8.5" r="1.3"/>'),
    ticket: svg('<path d="M3 8a2 2 0 0 0 2-2h14a2 2 0 0 0 2 2v2a2 2 0 0 0 0 4v2a2 2 0 0 0-2 2H5a2 2 0 0 0-2-2v-2a2 2 0 0 0 0-4z"/><path d="M13 6v2M13 11v2M13 16v2"/>'),
    crown: svg('<path d="m3 8 4 4 5-7 5 7 4-4-1.5 11h-15Z"/><path d="M6.5 22h11"/>'),
    refresh: svg('<path d="M20 12a8 8 0 1 1-2.3-5.7M20 3v5h-5"/>'),
    play: svg('<path d="M7 4.5 19 12 7 19.5z"/>'),
    skull: svg('<path d="M12 2a8 8 0 0 0-8 8c0 3 1.5 5 3 6v3a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-3c1.5-1 3-3 3-6a8 8 0 0 0-8-8Z"/><circle cx="9" cy="11" r="1.6" fill="currentColor"/><circle cx="15" cy="11" r="1.6" fill="currentColor"/><path d="M12 15v2"/>'),
    dice: svg('<rect x="3" y="3" width="18" height="18" rx="4"/><circle cx="8.5" cy="8.5" r="1.2" fill="currentColor"/><circle cx="15.5" cy="8.5" r="1.2" fill="currentColor"/><circle cx="12" cy="12" r="1.2" fill="currentColor"/><circle cx="8.5" cy="15.5" r="1.2" fill="currentColor"/><circle cx="15.5" cy="15.5" r="1.2" fill="currentColor"/>'),
    chart: svg('<path d="M4 20V4M4 20h16"/><path d="M8 16v-5M12 16V8M16 16v-3M20 16V6"/>'),
    sword: svg('<path d="M14.5 3.5 20 3l-.5 5.5L9 19l-4-4z"/><path d="M5 15l4 4M3 21l3-3M14 8l2 2"/>'),
    shield: svg('<path d="M12 2 4 5.5V11c0 5.5 3.5 9.5 8 11 4.5-1.5 8-5.5 8-11V5.5Z"/><path d="m8.5 12 2.5 2.5 4.5-5"/>'),
    bag: svg('<path d="M6 8h12l1.5 12.5a1.8 1.8 0 0 1-1.8 1.5H6.3a1.8 1.8 0 0 1-1.8-1.5z"/><path d="M9 11V6a3 3 0 0 1 6 0v5"/>')
  };

  /* ============================================================
     ТОСТЫ
     ============================================================ */
  var toastBox = null;
  function dmToast(msg, type) {
    if (!toastBox) return;
    var t = document.createElement('div');
    t.className = 'dm-toast ' + (type || 'good');
    var icon = type === 'bad' ? I.skull : type === 'gold' ? I.crown : I.check;
    t.innerHTML = icon + '<span>' + esc(msg) + '</span>';
    toastBox.appendChild(t);
    setTimeout(function () {
      t.classList.add('dm-out');
      setTimeout(function () { t.remove(); }, 320);
    }, 2600);
    while (toastBox.children.length > 4) toastBox.firstChild.remove();
  }

  /* ============================================================
     ЗАХВАТ ЖИВЫХ ССЫЛОК НА ДАННЫЕ ИГРЫ
     ============================================================ */
  function captureRefs() {
    // 1) живой S — через временный хук JSON.stringify + save()
    var js = JSON.stringify;
    try {
      JSON.stringify = function (o) {
        if (!FD.S && o && typeof o === 'object' && 'coins' in o && 'inv' in o && 'stats' in o) FD.S = o;
        return js.apply(JSON, arguments);
      };
      window.save();
    } finally {
      JSON.stringify = js;
    }
    // 2) живые TRACKS / RARITIES / MUTATIONS — через временный хук wpick
    var wp = window.wpick;
    try {
      window.wpick = function (arr, weights) {
        if (arr && arr.length) {
          if (arr[0] && arr[0].vol !== undefined && !FD.TRACKS.length) FD.TRACKS = arr;
          else if (!FD.RARITIES.length && arr.some(function (x) { return x && x.id === 'common'; })) FD.RARITIES = arr;
          else if (arr[0] && arr[0].id === 'none' && !FD.MUTATIONS.length) FD.MUTATIONS = arr.slice();
        }
        return wp(arr, weights);
      };
      window.pickTrack(1);
      window.pickRarity(1, 100, null);
      window.pickMutation(1, 100);
    } finally {
      window.wpick = wp;
    }
    // 3) живые объекты кейсов (категория при старте = 'все')
    try { FD.CASES = window.getFilteredCases().slice(); } catch (e) { FD.CASES = []; }
    FD.ready = !!(FD.S && FD.CASES.length && FD.TRACKS.length && FD.RARITIES.length);
    return FD.ready;
  }

  function getActiveCase() {
    var el = document.getElementById('caseName');
    if (el) {
      var name = el.textContent;
      for (var i = 0; i < FD.CASES.length; i++) if (FD.CASES[i].name === name) return FD.CASES[i];
    }
    for (var j = 0; j < FD.CASES.length; j++) if (FD.CASES[j].id === rt.activeCaseId) return FD.CASES[j];
    return FD.CASES[0] || null;
  }

  /* ============================================================
     ХУКИ ИГРОВЫХ ФУНКЦИЙ (ставятся один раз,
     поведение включается флагами state.*)
     ============================================================ */
  function installHooks() {
    ['spend', 'makeInstance', 'currentCaseCount', 'selCase', 'setMult', 'renderMults',
     'runUpgradeAnimation', 'setupCupsRound', 'pickCup', 'batSelect', 'addToInv']
      .forEach(function (n) { G[n] = window[n]; });

    /* бесконечные монеты */
    window.spend = function (n) {
      if (state.freeSpend) return true;
      return G.spend(n);
    };

    /* главный хук генерации дропа */
    window.makeInstance = function (luck, opts) {
      if (nerfDepth > 0) {
        var junk = G.makeInstance(luck, opts);
        junk.v = 1; junk.r = 'common'; junk.m = 'none'; delete junk.ms;
        return junk;
      }
      var L = luck;
      if (state.luckMult > 1) L = luck * state.luckMult;
      var o = opts;
      if (state.minRarity && (!o || !o.minRarity)) {
        o = Object.assign({}, o || {}, { minRarity: state.minRarity });
      }
      var inst = G.makeInstance(L, o);
      try {
        if (state.mutAlways && inst.m === 'none' && (!inst.ms || !inst.ms.length)) {
          var muts = FD.MUTATIONS.filter(function (m) { return m && m.name; });
          if (muts.length) {
            var top = muts.slice(Math.floor(muts.length / 2)); // верхняя половина по силе
            var m = top[Math.floor(Math.random() * top.length)];
            inst.m = m.id;
            var r = window.rarityOf(inst.r), t = window.trackOf(inst.t);
            if (r && t) inst.v = Math.max(1, Math.round(window.baseValue(t.vol) * r.mult * m.mult));
          }
        }
        if (state.hotAlways && !inst.hj) {
          inst.v = Math.max(1, Math.round(inst.v * (4 + Math.random() * 8)));
          inst.hj = 1;
        }
      } catch (e) { /* не ломаем игру из-за модификаторов */ }
      return inst;
    };

    /* снятие лимита 100 кейсов */
    window.currentCaseCount = function () {
      if (!state.uncap || !FD.ready) return G.currentCaseCount();
      var c = getActiveCase();
      if (!c) return G.currentCaseCount();
      if (rt.caseMult === 'MAX') return Math.max(0, Math.floor(FD.S.coins / c.price));
      return rt.caseMult;
    };

    /* следим за выбором кейса/множителя (внутренние let недоступны) */
    window.selCase = function (id) {
      rt.activeCaseId = id; rt.caseMult = 1;
      return G.selCase(id);
    };
    window.setMult = function (o) {
      rt.caseMult = o === 'MAX' ? 'MAX' : parseInt(o, 10);
      return G.setMult(o);
    };
    window.renderMults = function () {
      var r = G.renderMults();
      try {
        var act = document.querySelector('#caseMults .pill.active');
        if (act) {
          var t = act.textContent.trim();
          rt.caseMult = t === 'MAX' ? 'MAX' : (parseInt(t.replace('x', ''), 10) || 1);
        }
      } catch (e) { /* ignore */ }
      return r;
    };

    /* апгрейд всегда успешен */
    window.runUpgradeAnimation = function (inst, chance, nv, success) {
      return G.runUpgradeAnimation(inst, chance, nv, state.upgWin ? true : success);
    };

    /* стаканчики: перехватываем выигрышную позицию */
    window.setupCupsRound = function (cost, luck) {
      var mr = Math.random, first = null;
      Math.random = function () {
        var v = mr();
        if (first === null) first = v;
        return v;
      };
      try { G.setupCupsRound(cost, luck); } finally { Math.random = mr; }
      rt.cupsWin = first === null ? null : Math.floor(first * 3);
      if (state.cupsXray && rt.cupsWin != null) {
        var cup = document.querySelector('#cupsRow .cup[data-i="' + rt.cupsWin + '"]');
        if (cup) cup.classList.add('dm-cup-xray');
      }
    };
    window.pickCup = function (i) {
      if (state.cupsAuto && rt.cupsWin != null) return G.pickCup(rt.cupsWin);
      return G.pickCup(i);
    };

    /* баттлы: слабый соперник */
    window.batSelect = function (uid) {
      if (state.batWeak) {
        nerfDepth++;
        try { return G.batSelect(uid); } finally { nerfDepth--; }
      }
      return G.batSelect(uid);
    };

    /* автопродажа дешёвых дропов */
    window.addToInv = function (inst) {
      var r = G.addToInv(inst);
      if (state.autoSell > 0 && inst && inst.v < state.autoSell && nerfDepth === 0) {
        rt.sellQueue.push(inst.uid);
        if (rt.sellTimer) clearTimeout(rt.sellTimer);
        rt.sellTimer = setTimeout(flushSellQueue, 900);
      }
      return r;
    };
  }

  function flushSellQueue() {
    rt.sellTimer = null;
    if (!FD.S || !rt.sellQueue.length) return;
    var ids = rt.sellQueue.splice(0);
    var sum = 0, cnt = 0;
    for (var k = 0; k < ids.length; k++) {
      var idx = FD.S.inv.findIndex(function (x) { return x.uid === ids[k]; });
      if (idx >= 0) { sum += FD.S.inv[idx].v; FD.S.inv.splice(idx, 1); cnt++; }
    }
    if (cnt) {
      FD.S.stats.sold += cnt;
      window.addCoins(sum);
      window.save();
      dmToast('Автопродажа: ' + cnt + ' шт. за ' + num(sum), 'gold');
    }
  }

  /* ---------- удача кейсов (правка живых объектов) ---------- */
  function applyCaseLuck() {
    if (!FD.CASES.length) return;
    if (!rt.caseLuckOrig) {
      rt.caseLuckOrig = {};
      FD.CASES.forEach(function (c) { rt.caseLuckOrig[c.id] = c.luck; });
    }
    FD.CASES.forEach(function (c) {
      c.luck = state.caseLuck > 0 ? state.caseLuck : rt.caseLuckOrig[c.id];
    });
    try { if (document.getElementById('caseName')) window.refreshCaseUI(); } catch (e) { /* ignore */ }
  }

  /* ---------- автоматизация ---------- */
  function setAutoOpen(on) {
    state.autoOpen = on;
    if (rt.autoTimer) { clearInterval(rt.autoTimer); rt.autoTimer = null; }
    if (on) {
      rt.autoTimer = setInterval(function () {
        var btn = document.getElementById('caseBtn');
        if (!btn || btn.disabled) return;
        if (!state.freeSpend) {
          var c = getActiveCase();
          if (c && FD.S && FD.S.coins < c.price) {
            setAutoOpen(false);
            syncUI();
            dmToast('Авто-открытие остановлено: нет монет', 'bad');
            return;
          }
        }
        try { window.doOpenCase(); rt.autoOpened++; updateAutoCounter(); } catch (e) { /* ignore */ }
      }, Math.max(800, state.autoOpenMs));
    }
    persist();
  }
  function setAutoClaim(on) {
    state.autoClaim = on;
    if (rt.claimTimer) { clearInterval(rt.claimTimer); rt.claimTimer = null; }
    if (on) {
      rt.claimTimer = setInterval(function () {
        try {
          if (window.bpClaimable && window.bpClaimable() > 0) window.claimAllBp();
        } catch (e) { /* renderBp может ругнуться вне экрана — награды уже начислены */ }
      }, 4000);
    }
    persist();
  }

  /* ---------- счётчик активных читов ---------- */
  function activeCheats() {
    var n = 0;
    if (state.freeSpend) n++;
    if (state.uncap) n++;
    if (state.luckMult > 1) n++;
    if (state.caseLuck > 0) n++;
    if (state.minRarity) n++;
    if (state.mutAlways) n++;
    if (state.hotAlways) n++;
    if (state.upgWin) n++;
    if (state.cupsXray) n++;
    if (state.cupsAuto) n++;
    if (state.batWeak) n++;
    if (state.autoOpen) n++;
    if (state.autoSell > 0) n++;
    if (state.autoClaim) n++;
    return n;
  }

  /* ============================================================
     UI
     ============================================================ */
  var root, panel, fab;

  function toggleRow(id, icon, title, sub) {
    return '<div class="dm-row">' +
      '<div class="dm-row-txt"><div class="dm-row-title">' + icon + esc(title) + '</div>' +
      (sub ? '<div class="dm-row-sub">' + esc(sub) + '</div>' : '') + '</div>' +
      '<button class="dm-toggle" data-act="toggle" data-key="' + id + '" aria-pressed="false" role="switch" aria-label="' + esc(title) + '"></button>' +
      '</div>';
  }

  function buildUI() {
    root = document.createElement('div');
    root.id = 'dulban-root';
    root.innerHTML =
      '<button class="dm-fab" data-act="open" aria-label="Открыть Dulban Menu">' + I.logo + '</button>' +
      '<div class="dm-panel" hidden>' +
        '<div class="dm-head" data-drag>' +
          '<div class="dm-logo">' + I.logo + '</div>' +
          '<div class="dm-titles">' +
            '<div class="dm-title">DULBAN<span>&nbsp;MENU</span></div>' +
            '<div class="dm-cry">« I cant play fair »</div>' +
          '</div>' +
          '<div class="dm-head-btns">' +
            '<button class="dm-hbtn" data-act="collapse" aria-label="Свернуть">' + I.minus + '</button>' +
            '<button class="dm-hbtn" data-act="close" aria-label="Закрыть">' + I.x + '</button>' +
          '</div>' +
        '</div>' +
        '<div class="dm-body">' +
          '<nav class="dm-rail">' +
            railBtn('dash', I.dash, 'Дашборд') +
            railBtn('coins', I.coin, 'Монеты') +
            railBtn('drops', I.box, 'Дропы') +
            railBtn('spawn', I.wand, 'Спавнер') +
            railBtn('games', I.pad, 'Игры') +
            railBtn('auto', I.bot, 'Автомат') +
            railBtn('utils', I.wrench, 'Сервис') +
          '</nav>' +
          '<div class="dm-content">' +
            tabDash() + tabCoins() + tabDrops() + tabSpawn() + tabGames() + tabAuto() + tabUtils() +
          '</div>' +
        '</div>' +
        '<div class="dm-foot"><span>DULBAN · v' + VERSION + '</span><span><kbd>Insert</kbd> меню · <kbd>Esc</kbd> закрыть</span></div>' +
      '</div>' +
      '<div class="dm-toasts"></div>';
    document.body.appendChild(root);
    panel = root.querySelector('.dm-panel');
    fab = root.querySelector('.dm-fab');
    toastBox = root.querySelector('.dm-toasts');
    fillSpawner();
    fillRaritySelect();
    bindEvents();
    syncUI();
  }

  function railBtn(tab, icon, tip) {
    return '<button class="dm-tabbtn" data-act="tab" data-tab="' + tab + '" data-tip="' + tip + '" aria-label="' + tip + '">' + icon + '</button>';
  }

  /* ---------- вкладки ---------- */
  function tabDash() {
    return '<section class="dm-tab" data-tab="dash">' +
      '<div class="dm-sec">' + I.chart + 'Состояние</div>' +
      '<div class="dm-stats">' +
        stat('coins', I.coin, 'Монеты') +
        stat('inv', I.bag, 'Треков') +
        stat('invval', I.gem, 'Инвентарь, цена') +
        stat('games', I.dice, 'Игр сыграно') +
        stat('cases', I.box, 'Кейсов открыто') +
        stat('best', I.crown, 'Лучший дроп') +
      '</div>' +
      '<div class="dm-card dm-flat" style="display:flex;align-items:center;justify-content:space-between;gap:10px">' +
        '<span class="dm-badge"><span class="dm-dot"></span>Читов активно: <b data-stat="cheats">0</b></span>' +
        '<span style="font-size:10px;font-weight:800;letter-spacing:.1em;color:#8a8a86">FROSTDROP</span>' +
      '</div>' +
      '<div class="dm-sec">' + I.zap + 'Быстрые действия</div>' +
      '<div class="dm-btnrow">' +
        '<button class="dm-btn dm-primary" data-act="addCoins" data-n="100000">' + I.coin + '+100K</button>' +
        '<button class="dm-btn" data-act="omega">' + I.fire + 'Омега</button>' +
      '</div>' +
      '<div class="dm-btnrow">' +
        '<button class="dm-btn dm-good" data-act="godDrop">' + I.gem + 'God-дроп</button>' +
        '<button class="dm-btn dm-danger" data-act="sellAll">' + I.trash + 'Продать всё</button>' +
      '</div>' +
    '</section>';
  }
  function stat(key, icon, label) {
    return '<div class="dm-stat"><div class="dm-stat-k">' + icon + esc(label) + '</div><div class="dm-stat-v" data-stat="' + key + '">—</div></div>';
  }

  function tabCoins() {
    return '<section class="dm-tab" data-tab="coins">' +
      '<div class="dm-sec">' + I.coin + 'Выдача монет</div>' +
      '<div class="dm-card"><div class="dm-chips">' +
        chip('addCoins', 1000, '+1K') + chip('addCoins', 10000, '+10K') +
        chip('addCoins', 100000, '+100K') + chip('addCoins', 1000000, '+1M') +
      '</div>' +
      '<div class="dm-inline" style="margin-top:10px">' +
        '<input class="dm-input" id="dm-coins-n" type="number" min="0" step="1" placeholder="Своя сумма…">' +
        '<button class="dm-btn dm-primary" data-act="addCoinsCustom">' + I.zap + 'Выдать</button>' +
      '</div>' +
      '<div class="dm-inline" style="margin-top:8px">' +
        '<input class="dm-input" id="dm-coins-set" type="number" min="0" step="1" placeholder="Установить точно…">' +
        '<button class="dm-btn" data-act="setCoins">' + I.target + 'Задать</button>' +
      '</div></div>' +
      '<div class="dm-sec">' + I.shield + 'Режимы</div>' +
      '<div class="dm-card">' +
        toggleRow('freeSpend', I.zap, 'Бесконечные монеты', 'Любые покупки становятся бесплатными') +
      '</div>' +
      '<div class="dm-sec">' + I.dice + 'Счётчик игр</div>' +
      '<div class="dm-card"><div class="dm-inline">' +
        '<input class="dm-input" id="dm-games-n" type="number" min="0" step="1" placeholder="Напр. 1000 для «Path to Glory»">' +
        '<button class="dm-btn" data-act="setGames">' + I.crown + 'Задать</button>' +
      '</div><div class="dm-row-sub" style="margin-top:6px">Открывает награды «Path to Glory» (10 → 1000 игр)</div></div>' +
    '</section>';
  }
  function chip(act, n, label) {
    return '<button class="dm-chip" data-act="' + act + '" data-n="' + n + '">' + label + '</button>';
  }

  function tabDrops() {
    return '<section class="dm-tab" data-tab="drops">' +
      '<div class="dm-sec">' + I.box + 'Кейсы</div>' +
      '<div class="dm-card">' +
        toggleRow('uncap', I.rocket, 'Снять лимит 100 кейсов', 'Кнопка MAX открывает кейсы на все монеты') +
      '</div>' +
      '<div class="dm-sec">' + I.clover + 'Удача</div>' +
      '<div class="dm-card">' +
        '<div class="dm-row-title">' + I.clover + 'Множитель удачи (все дропы)</div>' +
        '<div class="dm-slider-wrap">' +
          '<input class="dm-slider" type="range" min="1" max="100" step="1" value="1" data-act="luckMult" aria-label="Множитель удачи">' +
          '<span class="dm-slider-val" id="dm-luck-val">×1</span>' +
        '</div>' +
        '<div class="dm-row-sub">Кейсы, колёса, стаканчики — вся генерация дропа</div>' +
      '</div>' +
      '<div class="dm-card">' +
        '<div class="dm-row-title">' + I.box + 'Удача всех кейсов</div>' +
        '<div class="dm-slider-wrap">' +
          '<input class="dm-slider" type="range" min="0" max="100" step="1" value="0" data-act="caseLuck" aria-label="Удача кейсов">' +
          '<span class="dm-slider-val" id="dm-cluck-val">выкл</span>' +
        '</div>' +
        '<div class="dm-row-sub">0 = стандартная удача кейсов (вернёт оригинал)</div>' +
      '</div>' +
      '<div class="dm-sec">' + I.gem + 'Модификаторы дропа</div>' +
      '<div class="dm-card">' +
        '<div class="dm-field"><span class="dm-label">Гарантированная редкость (минимум)</span>' +
        '<select class="dm-select" id="dm-minrar" data-act="minRarity"><option value="">— выключено —</option></select></div>' +
        toggleRow('mutAlways', I.dice, 'Мутация на каждом дропе', 'Если мутация не выпала — добавится сильная') +
        toggleRow('hotAlways', I.fire, 'Hot-джекпот всегда', 'Цена каждого дропа ×4–×12') +
      '</div>' +
    '</section>';
  }

  function tabSpawn() {
    return '<section class="dm-tab" data-tab="spawn">' +
      '<div class="dm-sec">' + I.wand + 'Спавнер треков</div>' +
      '<div class="dm-preview" id="dm-sp-preview">' +
        '<div><div class="dm-preview-name" id="dm-sp-name">—</div><div class="dm-preview-tags" id="dm-sp-tags"></div></div>' +
        '<div class="dm-preview-val"><small>цена</small><span id="dm-sp-val">0</span></div>' +
      '</div>' +
      '<div class="dm-field"><span class="dm-label">Поиск трека</span>' +
        '<input class="dm-input" id="dm-sp-search" type="text" placeholder="Название или артист…" data-act="spSearch">' +
      '</div>' +
      '<div class="dm-field"><span class="dm-label">Трек</span>' +
        '<select class="dm-select" id="dm-sp-track" data-act="spTrack" size="1"></select>' +
      '</div>' +
      '<div class="dm-field"><span class="dm-label">Редкость</span>' +
        '<select class="dm-select" id="dm-sp-rar" data-act="spRarity"></select>' +
      '</div>' +
      '<div class="dm-field"><span class="dm-label">Мутации (до 5)</span>' +
        '<div class="dm-mutbox" id="dm-sp-muts"></div>' +
      '</div>' +
      '<button class="dm-btn dm-primary dm-block" data-act="spawn">' + I.wand + 'Создать трек</button>' +
      '<div style="height:8px"></div>' +
      '<div class="dm-btnrow">' +
        '<button class="dm-btn dm-good" data-act="godDrop">' + I.gem + 'God-дроп</button>' +
        '<button class="dm-btn" data-act="omega">' + I.fire + 'Омега-джекпот</button>' +
      '</div>' +
    '</section>';
  }

  function tabGames() {
    return '<section class="dm-tab" data-tab="games">' +
      '<div class="dm-sec">' + I.rocket + 'Апгрейд</div>' +
      '<div class="dm-card">' +
        toggleRow('upgWin', I.check, 'Апгрейд всегда успешен', 'Даже шанс 0.1% сработает') +
      '</div>' +
      '<div class="dm-sec">' + I.eye + 'Стаканчики</div>' +
      '<div class="dm-card">' +
        toggleRow('cupsXray', I.eye, 'Рентген', 'Подсвечивает выигрышный стаканчик') +
        toggleRow('cupsAuto', I.target, 'Всегда угадывать', 'Любой клик попадает в выигрышный') +
      '</div>' +
      '<div class="dm-sec">' + I.sword + 'Баттлы</div>' +
      '<div class="dm-card">' +
        toggleRow('batWeak', I.sword, 'Слабый соперник', 'ИИ выставляет трек ценой 1 монета') +
      '</div>' +
      '<div class="dm-sec">' + I.ticket + 'Баттлпасс</div>' +
      '<div class="dm-card">' +
        '<div class="dm-btnrow" style="margin-bottom:8px">' +
          '<button class="dm-btn" data-act="addXp" data-n="1000">' + I.ticket + '+1000 XP</button>' +
          '<button class="dm-btn dm-primary" data-act="maxBp">' + I.crown + 'Максимум</button>' +
        '</div>' +
        '<button class="dm-btn dm-good dm-block" data-act="claimBp">' + I.dl + 'Забрать все награды</button>' +
        toggleRow('autoClaim', I.refresh, 'Авто-сбор наград', 'Проверка каждые 4 секунды') +
      '</div>' +
    '</section>';
  }

  function tabAuto() {
    return '<section class="dm-tab" data-tab="auto">' +
      '<div class="dm-sec">' + I.bot + 'Авто-открытие кейсов</div>' +
      '<div class="dm-note">' + I.info + '<span>Работает на экране «Кейсы». Жмёт «Открыть» с выбранным множителем. Сочетай с автопродажей и бесконечными монетами — получится ферма.</span></div>' +
      '<div class="dm-card">' +
        toggleRow('autoOpen', I.play, 'Авто-открытие', 'Открыто за сессию: 0') +
        '<div class="dm-field" style="margin-top:8px"><span class="dm-label">Скорость</span>' +
        '<select class="dm-select" data-act="autoSpeed">' +
          '<option value="1000">Турбо — 1 сек</option>' +
          '<option value="2500" selected>Норма — 2.5 сек</option>' +
          '<option value="7000">С анимацией — 7 сек</option>' +
        '</select></div>' +
      '</div>' +
      '<div class="dm-sec">' + I.trash + 'Автопродажа</div>' +
      '<div class="dm-card">' +
        '<div class="dm-field"><span class="dm-label">Продавать дропы дешевле (0 = выкл)</span>' +
        '<div class="dm-inline">' +
          '<input class="dm-input" id="dm-autosell-n" type="number" min="0" step="1" placeholder="Напр. 500">' +
          '<button class="dm-btn" data-act="setAutoSell">' + I.check + 'OK</button>' +
        '</div></div>' +
        '<div class="dm-row-sub" id="dm-autosell-status">Сейчас: выключено</div>' +
      '</div>' +
    '</section>';
  }

  function tabUtils() {
    return '<section class="dm-tab" data-tab="utils">' +
      '<div class="dm-sec">' + I.dl + 'Сейв</div>' +
      '<div class="dm-btnrow">' +
        '<button class="dm-btn" data-act="exportSave">' + I.dl + 'Экспорт</button>' +
        '<button class="dm-btn" data-act="importSave">' + I.ul + 'Импорт</button>' +
      '</div>' +
      '<div class="dm-card">' +
        '<div class="dm-field"><span class="dm-label">Редактор сейва (JSON)</span>' +
        '<textarea class="dm-textarea" id="dm-save-json" spellcheck="false"></textarea></div>' +
        '<div class="dm-btnrow" style="margin-bottom:0">' +
          '<button class="dm-btn" data-act="loadJson">' + I.refresh + 'Обновить</button>' +
          '<button class="dm-btn dm-primary" data-act="applyJson">' + I.check + 'Применить</button>' +
        '</div>' +
      '</div>' +
      '<div class="dm-sec">' + I.gem + 'Коллекция</div>' +
      '<div class="dm-btnrow">' +
        '<button class="dm-btn" data-act="unlockRar">' + I.gem + 'Открыть все редкости</button>' +
      '</div>' +
      '<div class="dm-sec">' + I.skull + 'Опасная зона</div>' +
      '<div class="dm-btnrow">' +
        '<button class="dm-btn" data-act="disableAll">' + I.shield + 'Выключить все читы</button>' +
        '<button class="dm-btn dm-danger" data-act="resetSave">' + I.trash + 'Сброс сейва</button>' +
      '</div>' +
      '<div class="dm-note">' + I.info + '<span>Dulban Menu меняет только локальную игру FrostDrop в твоём браузере. «I cant play fair» — это про синглплеер.</span></div>' +
    '</section>';
  }

  /* ---------- заполнение спавнера ---------- */
  function fillRaritySelect() {
    var sel = document.getElementById('dm-minrar');
    var spr = document.getElementById('dm-sp-rar');
    FD.RARITIES.forEach(function (r) {
      if (sel) {
        var o = document.createElement('option');
        o.value = r.id; o.textContent = r.name + ' (×' + r.mult + ')';
        sel.appendChild(o);
      }
      if (spr) {
        var o2 = document.createElement('option');
        o2.value = r.id; o2.textContent = r.name + ' (×' + r.mult + ')';
        spr.appendChild(o2);
      }
    });
    if (spr && FD.RARITIES.length) rt.spRarity = FD.RARITIES[0].id;
  }

  function fillSpawner() {
    var tsel = document.getElementById('dm-sp-track');
    if (!tsel) return;
    var q = rt.spSearch.toLowerCase();
    var list = FD.TRACKS.filter(function (t) {
      return !q || t.name.toLowerCase().indexOf(q) >= 0 || String(t.artist || '').toLowerCase().indexOf(q) >= 0;
    }).slice().sort(function (a, b) { return a.name.localeCompare(b.name); });
    tsel.innerHTML = list.map(function (t) {
      return '<option value="' + esc(t.id) + '">' + esc(t.name) + ' — ' + esc(t.artist || '?') + ' (' + window.baseValue(t.vol) + ')</option>';
    }).join('');
    if (list.length) {
      if (!list.some(function (t) { return t.id === rt.spTrack; })) rt.spTrack = list[0].id;
      tsel.value = rt.spTrack;
    } else {
      rt.spTrack = '';
    }
    var mbox = document.getElementById('dm-sp-muts');
    if (mbox && !mbox.childElementCount) {
      mbox.innerHTML = FD.MUTATIONS.filter(function (m) { return m && m.name; }).map(function (m) {
        return '<button class="dm-chip" data-act="spMut" data-id="' + esc(m.id) + '">' + esc(m.name) + ' ×' + m.mult + '</button>';
      }).join('');
    }
    updateSpawnPreview();
  }

  function updateSpawnPreview() {
    var t = window.trackOf(rt.spTrack);
    var r = window.rarityOf(rt.spRarity || (FD.RARITIES[0] && FD.RARITIES[0].id));
    var nameEl = document.getElementById('dm-sp-name');
    var tagsEl = document.getElementById('dm-sp-tags');
    var valEl = document.getElementById('dm-sp-val');
    if (!nameEl || !tagsEl || !valEl) return;
    if (!t || !r) { nameEl.textContent = '—'; tagsEl.innerHTML = ''; valEl.textContent = '0'; return; }
    var muts = rt.spMuts.map(function (id) { return window.mutationOf(id); }).filter(Boolean);
    var sum = muts.length ? muts.reduce(function (s, m) { return s + m.mult; }, 0) : 1;
    var v = Math.max(1, Math.round(window.baseValue(t.vol) * r.mult * sum));
    nameEl.textContent = t.name;
    tagsEl.innerHTML = '<span class="dm-tag">' + esc(r.name) + '</span>' +
      muts.map(function (m) { return '<span class="dm-tag">' + esc(m.name) + '</span>'; }).join('');
    valEl.textContent = num(v);
  }

  /* ---------- синхронизация UI с флагами ---------- */
  function syncUI() {
    if (!root) return;
    root.querySelectorAll('.dm-toggle').forEach(function (t) {
      var k = t.getAttribute('data-key');
      t.setAttribute('aria-pressed', state[k] ? 'true' : 'false');
    });
    root.querySelectorAll('.dm-tabbtn').forEach(function (b) {
      b.classList.toggle('active', b.getAttribute('data-tab') === state.tab);
    });
    root.querySelectorAll('.dm-tab').forEach(function (s) {
      s.classList.toggle('active', s.getAttribute('data-tab') === state.tab);
    });
    var lm = root.querySelector('[data-act="luckMult"]');
    if (lm) { lm.value = state.luckMult; }
    var lv = document.getElementById('dm-luck-val');
    if (lv) lv.textContent = '×' + state.luckMult;
    var cl = root.querySelector('[data-act="caseLuck"]');
    if (cl) { cl.value = state.caseLuck; }
    var cv = document.getElementById('dm-cluck-val');
    if (cv) cv.textContent = state.caseLuck > 0 ? '×' + state.caseLuck : 'выкл';
    var mr = document.getElementById('dm-minrar');
    if (mr) mr.value = state.minRarity;
    var sp = root.querySelector('[data-act="autoSpeed"]');
    if (sp) sp.value = String(state.autoOpenMs);
    var as = document.getElementById('dm-autosell-status');
    if (as) as.textContent = state.autoSell > 0 ? 'Сейчас: дешевле ' + num(state.autoSell) + ' — в монеты' : 'Сейчас: выключено';
    var asn = document.getElementById('dm-autosell-n');
    if (asn && !asn.value && state.autoSell > 0) asn.value = state.autoSell;
    root.querySelectorAll('.dm-mutbox .dm-chip').forEach(function (c) {
      c.classList.toggle('active', rt.spMuts.indexOf(c.getAttribute('data-id')) >= 0);
    });
    updateAutoCounter();
    updateStats(true);
  }

  function updateAutoCounter() {
    var row = root && root.querySelector('[data-key="autoOpen"]');
    if (!row) return;
    var sub = row.parentElement.querySelector('.dm-row-sub');
    if (sub) sub.textContent = 'Открыто за сессию: ' + rt.autoOpened;
  }

  /* ---------- дашборд ---------- */
  var lastStats = {};
  function updateStats(force) {
    if (!FD.S || !root) return;
    var invVal = 0;
    for (var i = 0; i < FD.S.inv.length; i++) invVal += FD.S.inv[i].v || 0;
    var vals = {
      coins: FD.S.coins,
      inv: FD.S.inv.length,
      invval: invVal,
      games: FD.S.games,
      cases: (FD.S.stats && FD.S.stats.cases) || 0,
      best: (FD.S.stats && FD.S.stats.bestValue) || 0,
      cheats: activeCheats()
    };
    for (var k in vals) {
      var el = root.querySelector('[data-stat="' + k + '"]');
      if (!el) continue;
      var txt = num(vals[k]);
      if (el.textContent !== txt) {
        el.textContent = txt;
        if (!force) {
          el.classList.remove('dm-bump');
          void el.offsetWidth; // перезапуск анимации
          el.classList.add('dm-bump');
        }
      }
    }
    lastStats = vals;
  }

  /* ---------- открытие/закрытие ---------- */
  function openPanel() {
    rt.panelOpen = true;
    panel.hidden = false;
    panel.classList.remove('dm-closing');
    panel.classList.add('dm-opening');
    fab.classList.add('dm-hidden');
    if (state.pos) applyPos();
    if (rt.statTimer) clearInterval(rt.statTimer);
    rt.statTimer = setInterval(function () { updateStats(false); }, 900);
    updateStats(true);
  }
  function closePanel() {
    rt.panelOpen = false;
    panel.classList.remove('dm-opening');
    panel.classList.add('dm-closing');
    fab.classList.remove('dm-hidden');
    if (rt.statTimer) { clearInterval(rt.statTimer); rt.statTimer = null; }
    setTimeout(function () { if (!rt.panelOpen) panel.hidden = true; }, 230);
  }
  function applyPos() {
    if (!state.pos) return;
    var x = Math.max(0, Math.min(window.innerWidth - 80, state.pos.x));
    var y = Math.max(0, Math.min(window.innerHeight - 60, state.pos.y));
    panel.style.left = x + 'px';
    panel.style.top = y + 'px';
    panel.style.right = 'auto';
  }

  /* ---------- события ---------- */
  function ink(btn, ev) {
    try {
      var r = btn.getBoundingClientRect();
      var d = document.createElement('span');
      d.className = 'dm-ink-dot';
      var size = Math.max(r.width, r.height);
      d.style.width = d.style.height = size + 'px';
      d.style.left = (ev.clientX - r.left - size / 2) + 'px';
      d.style.top = (ev.clientY - r.top - size / 2) + 'px';
      btn.appendChild(d);
      setTimeout(function () { d.remove(); }, 600);
    } catch (e) { /* ignore */ }
  }

  function bindEvents() {
    root.addEventListener('click', function (ev) {
      var el = ev.target.closest('[data-act]');
      if (!el) return;
      if (el.classList.contains('dm-btn') || el.classList.contains('dm-chip')) ink(el, ev);
      var act = el.getAttribute('data-act');
      handleAction(act, el, ev);
    });
    root.addEventListener('input', function (ev) {
      var el = ev.target.closest('[data-act]');
      if (!el) return;
      var act = el.getAttribute('data-act');
      if (act === 'luckMult') {
        state.luckMult = clampInt(el.value, 1, 100, 1);
        var lv = document.getElementById('dm-luck-val');
        if (lv) lv.textContent = '×' + state.luckMult;
        persist(); updateStats(true);
      } else if (act === 'caseLuck') {
        state.caseLuck = clampInt(el.value, 0, 100, 0);
        var cv = document.getElementById('dm-cluck-val');
        if (cv) cv.textContent = state.caseLuck > 0 ? '×' + state.caseLuck : 'выкл';
        applyCaseLuck(); persist(); updateStats(true);
      } else if (act === 'spSearch') {
        rt.spSearch = el.value;
        fillSpawner();
      }
    });
    root.addEventListener('change', function (ev) {
      var el = ev.target.closest('[data-act]');
      if (!el) return;
      var act = el.getAttribute('data-act');
      if (act === 'minRarity') { state.minRarity = el.value; persist(); updateStats(true); }
      else if (act === 'spTrack') { rt.spTrack = el.value; updateSpawnPreview(); }
      else if (act === 'spRarity') { rt.spRarity = el.value; updateSpawnPreview(); }
      else if (act === 'autoSpeed') {
        state.autoOpenMs = clampInt(el.value, 800, 20000, 2500);
        if (state.autoOpen) setAutoOpen(true); // перезапуск с новой скоростью
        persist();
      }
    });

    /* перетаскивание за шапку */
    var head = panel.querySelector('.dm-head');
    var drag = null;
    head.addEventListener('pointerdown', function (ev) {
      if (ev.target.closest('button')) return;
      var r = panel.getBoundingClientRect();
      drag = { dx: ev.clientX - r.left, dy: ev.clientY - r.top };
      head.setPointerCapture(ev.pointerId);
    });
    head.addEventListener('pointermove', function (ev) {
      if (!drag) return;
      state.pos = { x: ev.clientX - drag.dx, y: ev.clientY - drag.dy };
      applyPos();
    });
    head.addEventListener('pointerup', function () {
      if (drag) { drag = null; persist(); }
    });

    /* горячие клавиши */
    window.addEventListener('keydown', function (ev) {
      if (ev.key === 'Insert') {
        ev.preventDefault();
        rt.panelOpen ? closePanel() : openPanel();
      } else if (ev.key === 'Escape' && rt.panelOpen) {
        closePanel();
      }
    });
  }

  /* ---------- действия ---------- */
  function handleAction(act, el) {
    switch (act) {
      case 'open': openPanel(); break;
      case 'close': closePanel(); break;
      case 'collapse': panel.classList.toggle('dm-collapsed'); break;
      case 'tab':
        state.tab = el.getAttribute('data-tab');
        persist(); syncUI();
        if (state.tab === 'utils') loadJsonToEditor();
        break;

      case 'toggle': {
        var key = el.getAttribute('data-key');
        var on = !state[key];
        if (key === 'autoOpen') setAutoOpen(on);
        else if (key === 'autoClaim') setAutoClaim(on);
        else { state[key] = on; persist(); }
        syncUI();
        dmToast((on ? 'Включено: ' : 'Выключено: ') + (el.getAttribute('aria-label') || key), on ? 'good' : 'bad');
        break;
      }

      case 'addCoins': {
        var n = parseInt(el.getAttribute('data-n'), 10) || 0;
        window.addCoins(n); window.save();
        dmToast('+' + num(n) + ' монет', 'gold');
        updateStats(false);
        break;
      }
      case 'addCoinsCustom': {
        var inp = document.getElementById('dm-coins-n');
        var v = clampInt(inp && inp.value, 1, 2000000000, 0);
        if (!v) { dmToast('Введи сумму', 'bad'); break; }
        window.addCoins(v); window.save();
        dmToast('+' + num(v) + ' монет', 'gold');
        updateStats(false);
        break;
      }
      case 'setCoins': {
        var inp2 = document.getElementById('dm-coins-set');
        var v2 = clampInt(inp2 && inp2.value, 0, 2000000000, -1);
        if (v2 < 0) { dmToast('Введи число', 'bad'); break; }
        FD.S.coins = v2; window.refreshWallet(); window.save();
        dmToast('Баланс: ' + num(v2), 'gold');
        updateStats(false);
        break;
      }
      case 'setGames': {
        var inp3 = document.getElementById('dm-games-n');
        var v3 = clampInt(inp3 && inp3.value, 0, 2000000000, -1);
        if (v3 < 0) { dmToast('Введи число', 'bad'); break; }
        FD.S.games = v3;
        window.refreshWallet();
        try { window.checkGloryMilestones(); } catch (e) { /* ignore */ }
        window.save();
        dmToast('Игр сыграно: ' + num(v3), 'good');
        updateStats(false);
        break;
      }

      case 'omega': {
        try { window.omegaJackpot(getActiveCase() || undefined); dmToast('OMEGA JACKPOT!', 'gold'); }
        catch (e) { dmToast('Не получилось: ' + e.message, 'bad'); }
        updateStats(false);
        break;
      }
      case 'godDrop': {
        try {
          var topR = FD.RARITIES[FD.RARITIES.length - 1];
          var inst = window.makeInstance(5, { minRarity: topR.id });
          window.addToInv(inst); window.save();
          window.dropReveal(inst, 'Dulban Menu');
          dmToast('God-дроп выдан: ' + num(inst.v), 'gold');
        } catch (e) { dmToast('Ошибка: ' + e.message, 'bad'); }
        updateStats(false);
        break;
      }
      case 'sellAll': {
        try { window.sellAll(); } catch (e) { /* не на экране инвентаря */
          if (FD.S.inv.length && window.confirm('Продать все ' + FD.S.inv.length + ' треков?')) {
            var total = FD.S.inv.reduce(function (s, i) { return s + i.v; }, 0);
            FD.S.stats.sold += FD.S.inv.length;
            FD.S.inv = [];
            window.addCoins(total); window.save();
            dmToast('Продано за ' + num(total), 'gold');
          }
        }
        updateStats(false);
        break;
      }

      case 'spMut': {
        var id = el.getAttribute('data-id');
        var ix = rt.spMuts.indexOf(id);
        if (ix >= 0) rt.spMuts.splice(ix, 1);
        else if (rt.spMuts.length >= 5) { dmToast('Максимум 5 мутаций', 'bad'); break; }
        else rt.spMuts.push(id);
        el.classList.toggle('active', rt.spMuts.indexOf(id) >= 0);
        updateSpawnPreview();
        break;
      }
      case 'spawn': {
        var t = window.trackOf(rt.spTrack);
        var r = window.rarityOf(rt.spRarity);
        if (!t || !r) { dmToast('Выбери трек и редкость', 'bad'); break; }
        try {
          var muts = rt.spMuts.map(function (mid) { return window.mutationOf(mid); }).filter(Boolean);
          var sum = muts.length ? muts.reduce(function (s, m) { return s + m.mult; }, 0) : 1;
          var inst2 = window.makeInstance(1, { hot: false }); // для корректного uid
          inst2.t = t.id; inst2.r = r.id;
          inst2.ms = rt.spMuts.slice();
          inst2.m = rt.spMuts[0] || 'none';
          inst2.v = Math.max(1, Math.round(window.baseValue(t.vol) * r.mult * sum));
          inst2.hj = 0;
          window.addToInv(inst2); window.save();
          window.dropReveal(inst2, 'Dulban Menu');
          dmToast('Создано: ' + t.name + ' · ' + num(inst2.v), 'gold');
          try { window.checkAch(); } catch (e2) { /* ignore */ }
        } catch (e) { dmToast('Ошибка: ' + e.message, 'bad'); }
        updateStats(false);
        break;
      }

      case 'addXp': {
        var xp = parseInt(el.getAttribute('data-n'), 10) || 0;
        window.addXp(xp);
        dmToast('+' + num(xp) + ' XP баттлпасса', 'good');
        break;
      }
      case 'maxBp': {
        var total2 = 0;
        for (var s2 = 0; s2 < window.bpTotalSteps(); s2++) total2 += window.bpStepXp(s2);
        FD.S.bp.xp = Math.max(FD.S.bp.xp || 0, total2);
        window.save();
        dmToast('Баттлпасс прокачан до максимума', 'gold');
        break;
      }
      case 'claimBp': {
        try { window.claimAllBp(); dmToast('Награды собраны', 'gold'); }
        catch (e) { dmToast('Награды начислены (экран баттлпасса обновится при открытии)', 'good'); }
        updateStats(false);
        break;
      }

      case 'setAutoSell': {
        var asn = document.getElementById('dm-autosell-n');
        state.autoSell = clampInt(asn && asn.value, 0, 2000000000, 0);
        persist(); syncUI();
        dmToast(state.autoSell > 0 ? 'Автопродажа дешевле ' + num(state.autoSell) : 'Автопродажа выключена', 'good');
        break;
      }

      case 'exportSave': {
        try { window.exportSave(); dmToast('Сейв экспортирован', 'good'); }
        catch (e) { dmToast('Ошибка экспорта', 'bad'); }
        break;
      }
      case 'importSave': {
        var fi = document.createElement('input');
        fi.type = 'file'; fi.accept = '.json,application/json';
        fi.onchange = function (e) { try { window.importSave(e); } catch (err) { dmToast('Ошибка импорта', 'bad'); } };
        fi.click();
        break;
      }
      case 'loadJson': loadJsonToEditor(); dmToast('Сейв загружен в редактор', 'good'); break;
      case 'applyJson': {
        var ta = document.getElementById('dm-save-json');
        try {
          var obj = JSON.parse(ta.value);
          Object.keys(FD.S).forEach(function (k2) { if (!(k2 in obj)) delete FD.S[k2]; });
          Object.assign(FD.S, obj);
          window.save(); window.refreshWallet();
          dmToast('Сейв применён. Для полной синхронизации обнови страницу', 'good');
          updateStats(false);
        } catch (e) { dmToast('Невалидный JSON: ' + e.message, 'bad'); }
        break;
      }
      case 'unlockRar': {
        FD.RARITIES.forEach(function (r3) { FD.S.seen[r3.id] = true; });
        window.save();
        dmToast('Все редкости открыты в коллекции', 'gold');
        break;
      }
      case 'disableAll': {
        state.freeSpend = false; state.uncap = false; state.luckMult = 1;
        state.caseLuck = 0; state.minRarity = ''; state.mutAlways = false;
        state.hotAlways = false; state.upgWin = false; state.cupsXray = false;
        state.cupsAuto = false; state.batWeak = false; state.autoSell = 0;
        setAutoOpen(false); setAutoClaim(false);
        applyCaseLuck(); persist(); syncUI();
        dmToast('Все читы выключены. Играем честно… пока что', 'bad');
        break;
      }
      case 'resetSave': {
        try { window.resetSave(); } catch (e) { dmToast('Ошибка сброса', 'bad'); }
        break;
      }
    }
  }

  function loadJsonToEditor() {
    var ta = document.getElementById('dm-save-json');
    if (ta && FD.S) {
      try { ta.value = JSON.stringify(FD.S, null, 2); } catch (e) { ta.value = '{}'; }
    }
  }

  /* ============================================================
     ЗАПУСК
     ============================================================ */
  function ensureFonts() {
    if (document.getElementById('dulban-fonts')) return;
    var l = document.createElement('link');
    l.id = 'dulban-fonts';
    l.rel = 'stylesheet';
    l.href = 'https://fonts.googleapis.com/css2?family=Orbitron:wght@600;800;900&family=Montserrat:wght@500;600;700;800;900&family=Montserrat+Alternates:wght@700;800&display=swap';
    (document.head || document.documentElement).appendChild(l);
  }

  function boot(tries) {
    // ждём, пока игра объявит свои глобальные функции
    var need = ['save', 'wpick', 'pickTrack', 'pickRarity', 'pickMutation',
      'getFilteredCases', 'makeInstance', 'addCoins', 'addToInv', 'spend',
      'currentCaseCount', 'selCase', 'setMult', 'renderMults', 'doOpenCase'];
    var ok = need.every(function (n) { return typeof window[n] === 'function'; });
    if (!ok || !document.body) {
      if (tries > 80) { console.warn('[Dulban Menu] Игра FrostDrop не найдена на странице.'); return; }
      setTimeout(function () { boot(tries + 1); }, 250);
      return;
    }
    if (!captureRefs()) {
      if (tries > 80) { console.warn('[Dulban Menu] Не удалось получить состояние игры.'); return; }
      setTimeout(function () { boot(tries + 1); }, 250);
      return;
    }

    restore();
    installHooks();
    ensureFonts();
    buildUI();
    applyCaseLuck();
    if (state.autoOpen) setAutoOpen(true);
    if (state.autoClaim) setAutoClaim(true);

    window.__DULBAN__ = { version: VERSION, FD: FD, state: state, rt: rt, toast: dmToast };
    console.log('%c DULBAN MENU v' + VERSION + ' %c I cant play fair ',
      'background:#0d0d0d;color:#fff;font-weight:900;padding:3px 6px;border-radius:6px 0 0 6px',
      'background:#fff;color:#0d0d0d;font-weight:700;padding:3px 6px;border:1px solid #0d0d0d;border-radius:0 6px 6px 0');
    dmToast('Dulban Menu загружен — клавиша Insert', 'good');

    /* хук для автотестов/QA */
    if (window.__DM_QA) {
      if (window.__DM_QA.tab) { state.tab = window.__DM_QA.tab; syncUI(); if (state.tab === 'utils') loadJsonToEditor(); }
      if (window.__DM_QA.open) openPanel();
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () { boot(0); });
  } else {
    boot(0);
  }
})();
