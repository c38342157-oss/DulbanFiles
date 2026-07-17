/* ============================================================
   DULBAN LIB · dulban-svg.js
   Работа со спрайтами и SVG-элементами + неровный неон по буквам.
   Экспорт: window.DulbanSVG

   В Tampermonkey:
     DulbanSVG.injectSprite(GM_getResourceText('DB_ICONS'));
     btn.append(DulbanSVG.icon('bolt', { size: 18 }));
   ============================================================ */
(function (g) {
  'use strict';

  var NS = 'http://www.w3.org/2000/svg';

  var DulbanSVG = {
    /** Встроить спрайт (строку <svg>...</svg>) в документ скрытым блоком,
     *  после чего доступны ссылки <use href="#id">. Безопасно вызывать повторно. */
    injectSprite: function (svgText) {
      var doc = new DOMParser().parseFromString(svgText, 'image/svg+xml');
      var root = doc.documentElement;
      if (!root || root.nodeName === 'parsererror') return null;
      var id = root.getAttribute('data-sprite-id') || 'db-sprite-' + Math.random().toString(36).slice(2, 8);
      if (document.getElementById(id)) return document.getElementById(id);
      var el = document.importNode(root, true);
      el.setAttribute('id', id);
      el.setAttribute('aria-hidden', 'true');
      el.style.cssText = 'position:absolute;width:0;height:0;overflow:hidden';
      (document.body || document.documentElement).appendChild(el);
      return el;
    },

    /** Создать <svg><use href="#db-icon-имя"></use></svg>. Цвет наследуется от текста (currentColor). */
    icon: function (name, opts) {
      opts = opts || {};
      var size = opts.size || 20;
      var svg = document.createElementNS(NS, 'svg');
      svg.setAttribute('width', size);
      svg.setAttribute('height', size);
      svg.setAttribute('viewBox', opts.viewBox || '0 0 24 24');
      svg.setAttribute('fill', 'none');
      svg.setAttribute('aria-hidden', 'true');
      var use = document.createElementNS(NS, 'use');
      use.setAttribute('href', '#db-icon-' + name);
      svg.appendChild(use);
      if (opts.className) svg.setAttribute('class', opts.className);
      return svg;
    },

    /** То же для фигур из dulban-shapes.svg (viewBox 0 0 100 100). */
    shape: function (name, opts) {
      opts = opts || {};
      opts.viewBox = '0 0 100 100';
      var svg = DulbanSVG.icon(name, opts);
      svg.firstChild.setAttribute('href', '#db-shape-' + name);
      return svg;
    },

    /** Неровный неон: режет текст элемента на буквы <span class="db-neon-letter">
     *  и раздаёт каждой случайную фазу/скорость — одни буквы горят ярче,
     *  другие тусклее, как у живой вывески. Требует dulban-neon.css. */
    unevenNeon: function (el, opts) {
      opts = opts || {};
      var text = el.textContent;
      el.textContent = '';
      el.setAttribute('aria-label', text);
      Array.prototype.forEach.call(text, function (ch) {
        if (ch === ' ') { el.appendChild(document.createTextNode('\u00a0')); return; }
        var s = document.createElement('span');
        s.className = 'db-neon-letter';
        s.setAttribute('aria-hidden', 'true');
        s.textContent = ch;
        s.style.setProperty('--dur', (opts.minDur || 1.6) + Math.random() * (opts.spread || 2.4) + 's');
        s.style.setProperty('--del', (-Math.random() * 4).toFixed(2) + 's');
        el.appendChild(s);
      });
      return el;
    },
  };

  g.DulbanSVG = DulbanSVG;
})(typeof window !== 'undefined' ? window : globalThis);
