// ==UserScript==
// @name         Dulban Menu — FrostDrop (GitHub loader)
// @namespace    https://github.com/c38342157-oss/DulbanFiles
// @version      1.1.0
// @description  «I cant play fair» — W&B-меню для FrostDrop с Dulban Lib, SVG, tween и tilt.
// @author       Dulban
// @match        *://*/*FrostDrop*
// @match        file:///*FrostDrop*
// @run-at       document-idle
// @grant        none
// ==/UserScript==

/*
  Все зависимости лежат В КОРНЕ репозитория:
  https://github.com/c38342157-oss/DulbanFiles

  Лоадер использует jsDelivr, потому что он отдаёт корректные MIME-типы
  для CSS, JS и SVG. Основное меню запускается последним, когда библиотеки
  уже доступны в window.
*/
(function () {
  'use strict';

  if (window.__DULBAN_LOADER__) return;
  window.__DULBAN_LOADER__ = true;

  var GH_USER = 'c38342157-oss';
  var GH_REPO = 'DulbanFiles';
  var GH_REF = 'main';
  var VERSION = '1.1.0';
  var BASE = 'https://cdn.jsdelivr.net/gh/' + GH_USER + '/' + GH_REPO + '@' + GH_REF + '/';

  var CSS_FILES = [
    'dulban-easings.css',
    'dulban-core.css',
    'dulban-neon.css',
    'dulban-tilt.css',
    'dulban-menu.css'
  ];

  /* Порядок важен: tween использует DulbanEase, меню использует всё остальное. */
  var JS_LIBS = [
    'dulban-easings.js',
    'dulban-tween.js',
    'dulban-tilt.js',
    'dulban-svg.js'
  ];

  var SVG_SPRITES = ['dulban-shapes.svg', 'dulban-icons.svg'];

  function url(file) {
    return BASE + file + '?dm=' + encodeURIComponent(VERSION);
  }

  function addCss(file) {
    if (document.querySelector('link[data-dulban-file="' + file + '"]')) return;
    var link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = url(file);
    link.setAttribute('data-dulban-file', file);
    link.onerror = function () {
      console.error('[Dulban Menu] Не удалось загрузить CSS:', file);
    };
    (document.head || document.documentElement).appendChild(link);
  }

  function loadScript(file) {
    return new Promise(function (resolve) {
      if (document.querySelector('script[data-dulban-file="' + file + '"]')) {
        resolve(true);
        return;
      }
      var script = document.createElement('script');
      script.src = url(file);
      script.async = false;
      script.setAttribute('data-dulban-file', file);
      script.onload = function () { resolve(true); };
      script.onerror = function () {
        console.error('[Dulban Menu] Не удалось загрузить JS:', file);
        resolve(false); // библиотека декоративная: меню всё равно запустится
      };
      (document.head || document.documentElement).appendChild(script);
    });
  }

  function injectSprite(file) {
    if (!window.DulbanSVG || typeof window.fetch !== 'function') return Promise.resolve(false);
    return fetch(url(file))
      .then(function (response) {
        if (!response.ok) throw new Error('HTTP ' + response.status);
        return response.text();
      })
      .then(function (svg) {
        window.DulbanSVG.injectSprite(svg);
        return true;
      })
      .catch(function (error) {
        console.warn('[Dulban Menu] SVG-спрайт не загружен:', file, error);
        return false;
      });
  }

  CSS_FILES.forEach(addCss);

  var chain = Promise.resolve();
  JS_LIBS.forEach(function (file) {
    chain = chain.then(function () { return loadScript(file); });
  });

  chain
    .then(function () {
      return Promise.all(SVG_SPRITES.map(injectSprite));
    })
    .then(function () {
      return loadScript('dulban-menu.js');
    })
    .then(function () {
      console.log('[Dulban Menu] GitHub-комплект загружен:', BASE);
    });
})();
