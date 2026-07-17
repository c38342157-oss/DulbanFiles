// ==UserScript==
// @name         Dulban Menu — FrostDrop (GitHub loader)
// @namespace    https://github.com/c38342157-oss/DulbanFiles
// @version      1.0.0
// @description  «I cant play fair» — чит-меню для FrostDrop. Лоадер: подгружает CSS и JS из твоего GitHub-репозитория через jsDelivr.
// @author       Dulban
// @match        *://*/*FrostDrop*
// @match        file:///*FrostDrop*
// @run-at       document-idle
// @grant        none
// ==/UserScript==

/*
  НАСТРОЙКА (3 константы ниже):
  1. Создай публичный репозиторий на GitHub (напр. dulban-menu).
  2. Залей туда файлы dulban-menu.css и dulban-menu.js (в корень).
  3. Впиши свой логин/репо/ветку ниже — и всё.
  jsDelivr кеширует файлы: после обновления в репо можно указать тег/коммит
  вместо ветки, например '@v1.0.0' или '@abc1234'.

  Если не хочешь возиться с GitHub — установи dulban.bundle.user.js:
  там всё в одном файле и ничего настраивать не надо.
*/
(function () {
  'use strict';

  var GH_USER = 'c38342157-oss'; // GitHub пользователя
  var GH_REPO = 'DulbanFiles';   // репозиторий с файлами меню
  var GH_REF  = 'main';          // ветка, тег или коммит

  var BASE = 'https://cdn.jsdelivr.net/gh/' + GH_USER + '/' + GH_REPO + '@' + GH_REF + '/';

  var css = document.createElement('link');
  css.rel = 'stylesheet';
  css.href = BASE + 'dulban-menu.css';
  css.onerror = function () { console.error('[Dulban Menu] Не удалось загрузить CSS с ' + css.href); };
  (document.head || document.documentElement).appendChild(css);

  var js = document.createElement('script');
  js.src = BASE + 'dulban-menu.js';
  js.onerror = function () { console.error('[Dulban Menu] Не удалось загрузить JS с ' + js.src); };
  (document.head || document.documentElement).appendChild(js);
})();
