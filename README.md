# DULBAN MENU + DULBAN LIB

> W&B-меню для FrostDrop — **I cant play fair**.

## Важно: структура репозитория

Все файлы находятся **в корне** ветки `main`:

```text
DulbanFiles/
├── dulban-core.css
├── dulban-easings.css
├── dulban-neon.css
├── dulban-tilt.css
├── dulban-menu.css
├── dulban-easings.js
├── dulban-tween.js
├── dulban-tilt.js
├── dulban-svg.js
├── dulban-icons.svg
├── dulban-shapes.svg
├── dulban-menu.js
└── dulban.user.js
```

## Установка

Установи `dulban.user.js` в Tampermonkey. Лоадер уже настроен на:

```text
https://github.com/c38342157-oss/DulbanFiles
```

Открытие меню: **Insert** или кнопка с SVG-молнией справа снизу. Закрытие: **Esc**.

Для локального `FrostDrop.html` разреши Tampermonkey доступ к файловым URL.

## Реальные CDN-адреса

Префикс:

```text
https://cdn.jsdelivr.net/gh/c38342157-oss/DulbanFiles@main/
```

CSS:

```text
dulban-easings.css
dulban-core.css
dulban-neon.css
dulban-tilt.css
dulban-menu.css
```

JS загружается строго по порядку:

```text
dulban-easings.js
dulban-tween.js
dulban-tilt.js
dulban-svg.js
dulban-menu.js
```

SVG-спрайты:

```text
dulban-shapes.svg
dulban-icons.svg
```

`dulban.user.js` автоматически подключает всё перечисленное, внедряет SVG-спрайты через `DulbanSVG.injectSprite()` и запускает `dulban-menu.js` последним.

## Что из библиотеки реально используется

- `DulbanEase` — кривые анимаций.
- `DulbanTween` — появление панели и вкладок.
- `DulbanTilt` — мягкий 3D-прогиб FAB-кнопки и карточек статистики.
- `DulbanSVG` + `dulban-icons.svg` — SVG-молния в кнопке запуска.
- CSS-модули подключаются до основного `dulban-menu.css`.
- `dulban-neon.css` доступен для специальных эффектов, но базовая тема остаётся строгой W&B.

Если библиотека не загрузится, основное меню всё равно запустится с CSS-анимациями как фолбэком.

## Переключатели v1.1

В активном состоянии чернеет только внутренняя дорожка тумблера, а бегунок становится белым. Состояние синхронизируется одновременно через `aria-pressed="true"` и класс `.is-on`, чтобы стили FrostDrop не могли скрыть индикацию.

## Шрифты

Из Google Fonts загружаются Orbitron, Montserrat и Montserrat Alternates. TT Gertika, TT Polls, TT Fors и TT Interphases Pro используются как системные fallback-шрифты, если установлены локально.
