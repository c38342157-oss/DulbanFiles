# DULBAN LIB

> Библиотека дизайн-зависимостей для Tampermonkey-скриптов (Dulban Menu).
> Стиль: **W&B** — белый фон, чёрные края/детали + неоновые акценты.
> Боевой клич: *«I cant play fair»*

## Структура

```
dulban-lib/
├── css/
│   ├── dulban-core.css      — база W&B: кнопки, карточки, чипы, фигуры (круги, квадраты, гексы, блобы)
│   ├── dulban-neon.css      — неон: перелив (где-то светлее/где-то темнее), бегущая рамка, фликер
│   ├── dulban-easings.css   — все кривые (ease/cubic/expo/back...) как CSS-переменные + утилиты
│   └── dulban-tilt.css      — стили для 3D-наклона (перспектива, блик, параллакс-слои)
├── js/
│   ├── dulban-easings.js    — 30+ функций плавности (Penner easings) → window.DulbanEase
│   ├── dulban-tween.js      — tween-движок в духе After Effects (keyframes, timeline, stagger) → window.DulbanTween
│   ├── dulban-tilt.js       — «прогибание» элемента в 3D под курсором + блик → window.DulbanTilt
│   └── dulban-svg.js        — иконки/фигуры из SVG-спрайтов, неровный неон по буквам → window.DulbanSVG
├── svg/
│   ├── dulban-shapes.svg    — спрайт фигур: круг, квадрат, ромб, гекс, звезда, блоб, кольцо...
│   └── dulban-icons.svg     — спрайт UI-иконок вместо эмодзи: шестерёнка, молния, глаз, play...
└── demo/
    └── dulban-demo.html     — ВСЕ примеры кода в одном .html: неон, наклон, кривые, tweening
```

## Подключение в Tampermonkey

Залей папку в GitHub-репозиторий и подгружай через jsDelivr (у raw.githubusercontent неправильный MIME для @require — jsDelivr надёжнее):

```js
// ==UserScript==
// @name         Dulban Menu
// @namespace    dulban
// @version      1.0
// @match        *://*/*
// @grant        GM_addStyle
// @grant        GM_getResourceText
// @resource     DB_CORE    https://cdn.jsdelivr.net/gh/<user>/<repo>@main/css/dulban-core.css
// @resource     DB_NEON    https://cdn.jsdelivr.net/gh/<user>/<repo>@main/css/dulban-neon.css
// @resource     DB_EASE    https://cdn.jsdelivr.net/gh/<user>/<repo>@main/css/dulban-easings.css
// @resource     DB_TILT    https://cdn.jsdelivr.net/gh/<user>/<repo>@main/css/dulban-tilt.css
// @resource     DB_SHAPES  https://cdn.jsdelivr.net/gh/<user>/<repo>@main/svg/dulban-shapes.svg
// @resource     DB_ICONS   https://cdn.jsdelivr.net/gh/<user>/<repo>@main/svg/dulban-icons.svg
// @require      https://cdn.jsdelivr.net/gh/<user>/<repo>@main/js/dulban-easings.js
// @require      https://cdn.jsdelivr.net/gh/<user>/<repo>@main/js/dulban-tween.js
// @require      https://cdn.jsdelivr.net/gh/<user>/<repo>@main/js/dulban-tilt.js
// @require      https://cdn.jsdelivr.net/gh/<user>/<repo>@main/js/dulban-svg.js
// ==/UserScript==

(function () {
  'use strict';
  // 1) стили
  GM_addStyle(GM_getResourceText('DB_EASE'));
  GM_addStyle(GM_getResourceText('DB_CORE'));
  GM_addStyle(GM_getResourceText('DB_NEON'));
  GM_addStyle(GM_getResourceText('DB_TILT'));
  // 2) SVG-спрайты (иконки станут доступны как <use href="#db-icon-...">)
  DulbanSVG.injectSprite(GM_getResourceText('DB_SHAPES'));
  DulbanSVG.injectSprite(GM_getResourceText('DB_ICONS'));

  // 3) пример: кнопка меню
  const btn = document.createElement('button');
  btn.className = 'db-btn db-btn--ink db-tilt';
  btn.append(DulbanSVG.icon('bolt', { size: 18 }), ' DULBAN');
  document.body.appendChild(btn);
  DulbanTilt.attach(btn, { press: true, glare: true });

  // 4) пример: анимация появления (tween как в AE)
  DulbanTween.to(btn, { duration: 700, ease: 'outBack', y: [40, 0], opacity: [0, 1] });
})();
```

## Шрифты

Библиотека рассчитана на **Orbitron** (диспл.) и **Montserrat / Montserrat Alternates** (текст) c фолбэками
на TT Fors / TT Interphases Pro / system-ui. Google Fonts:

```js
GM_addStyle('@import url("https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Montserrat:wght@500;600;800&family=Montserrat+Alternates:wght@700&display=swap");');
```

TT-шрифты (TT Gertika, TT Polls, TT Fors, TT Interphases Pro) — коммерческие: положи `.woff2` в репозиторий и подключи через `@font-face`, они уже прописаны в фолбэк-цепочках `--db-font-display` / `--db-font-body`.

## Быстрые рецепты

```js
// Неровный неон по буквам (каждая буква дышит в своей фазе)
DulbanSVG.unevenNeon(document.querySelector('.logo'));

// 3D-прогиб карточки под мышкой
DulbanTilt.attach(el, { max: 14, press: true, glare: true, scale: 0.985 });

// Tweening как в After Effects: ключевые кадры со своими кривыми
DulbanTween.keyframes(el, {
  prop: 'x', duration: 1200,
  frames: [
    { t: 0,   v: 0 },
    { t: 0.35, v: 220, ease: 'outCubic' },
    { t: 0.6,  v: 180, ease: 'inOutQuad' },
    { t: 1,   v: 400, ease: 'inOutQuint' },
  ],
});

// Timeline (последовательность с оффсетами, как слои в AE)
DulbanTween.timeline()
  .add(logo,  { duration: 500, ease: 'outExpo',  y: [-30, 0], opacity: [0, 1] })
  .add(menu,  { duration: 600, ease: 'outBack',  scale: [0.9, 1], opacity: [0, 1] }, '-=200')
  .add(items, { duration: 400, ease: 'outCubic', x: [-20, 0], opacity: [0, 1], stagger: 60 })
  .play();
```

Все живые примеры — в `demo/dulban-demo.html` (открой локально в браузере, файлы подключаются относительными путями).
