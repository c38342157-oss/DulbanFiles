/* Сборка Dulban Menu:
   1) dulban.bundle.user.js — автономный юзерскрипт (CSS вшит внутрь)
   2) копии css/js в папку расширения Firefox
   3) QA-харнессы для скриншотов */
const fs = require('fs');
const path = require('path');

const dir = __dirname;
const css = fs.readFileSync(path.join(dir, 'dulban-menu.css'), 'utf8');
const js = fs.readFileSync(path.join(dir, 'dulban-menu.js'), 'utf8');

const header = `// ==UserScript==
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

`;

const bundle = header +
  '(function () {\n' +
  "  'use strict';\n" +
  '  var css = ' + JSON.stringify(css) + ';\n' +
  "  var st = document.createElement('style');\n" +
  "  st.id = 'dulban-style';\n" +
  '  st.textContent = css;\n' +
  '  (document.head || document.documentElement).appendChild(st);\n' +
  '})();\n\n' + js;

fs.writeFileSync(path.join(dir, 'dulban.bundle.user.js'), bundle);
console.log('OK dulban.bundle.user.js', bundle.length, 'bytes');

// копии для расширения
fs.copyFileSync(path.join(dir, 'dulban-menu.css'), path.join(dir, 'firefox-extension', 'dulban-menu.css'));
fs.copyFileSync(path.join(dir, 'dulban-menu.js'), path.join(dir, 'firefox-extension', 'dulban-menu.js'));
console.log('OK firefox-extension copies');

// QA-харнессы
const game = fs.readFileSync('/data/FrostDrop.html', 'utf8');
const tabs = ['dash', 'coins', 'drops', 'spawn', 'games', 'auto', 'utils'];
const qaDir = '/data/qa';
if (!fs.existsSync(qaDir)) fs.mkdirSync(qaDir);
for (const tab of tabs) {
  const inject = '\n<link rel="stylesheet" href="file://' + path.join(dir, 'dulban-menu.css') + '">' +
    '\n<script>window.__DM_QA={open:true,tab:' + JSON.stringify(tab) + '};</script>' +
    '\n<script src="file://' + path.join(dir, 'dulban-menu.js') + '"></script>\n';
  fs.writeFileSync(path.join(qaDir, 'test-' + tab + '.html'), game.replace('</body>', inject + '</body>'));
}
// закрытая панель (только FAB)
const injectClosed = '\n<link rel="stylesheet" href="file://' + path.join(dir, 'dulban-menu.css') + '">' +
  '\n<script src="file://' + path.join(dir, 'dulban-menu.js') + '"></script>\n';
fs.writeFileSync(path.join(qaDir, 'test-closed.html'), game.replace('</body>', injectClosed + '</body>'));
console.log('OK qa harnesses');
