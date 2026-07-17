/* ============================================================
   DULBAN LIB · dulban-tilt.js
   3D-наклон/прогиб элемента под курсором + блик.
   Экспорт: window.DulbanTilt
   Требует css/dulban-tilt.css (классы .db-tilt, .db-tilt__glare).

   Режимы:
   - press:true  — элемент «прогибается»: угол под мышкой уходит
                   ВГЛУБЬ экрана (как кнопка, которую продавливают)
   - press:false — классический tilt: угол под мышкой тянется К курсору

   Пример:
     DulbanTilt.attach(btn, { max: 12, press: true, glare: true });
     DulbanTilt.init(); // автоподхват всех [data-db-tilt]
   ============================================================ */
(function (g) {
  'use strict';

  var REDUCED = false;
  try {
    REDUCED = g.matchMedia && g.matchMedia('(prefers-reduced-motion: reduce)').matches;
  } catch (e) { /* старые браузеры */ }

  var DEFAULTS = {
    max: 10,          // макс. угол наклона, градусы
    perspective: 900, // глубина сцены, px
    press: true,      // прогиб под курсор (false = классический tilt)
    scale: 0.985,     // масштаб при наведении (для press чуть меньше 1)
    sink: 10,         // насколько px элемент утапливается по Z при press
    glare: true,      // блик, следующий за курсором
    ease: 0.14,       // сглаживание (0..1): меньше = плавнее/ленивее
  };

  function attach(el, opts) {
    if (!el || el._dbTilt) return el && el._dbTilt;
    var o = Object.assign({}, DEFAULTS, opts || {});
    var state = {
      opts: o,
      // текущие и целевые значения (для lerp-сглаживания)
      rx: 0, ry: 0, tz: 0, sc: 1,
      trx: 0, try_: 0, ttz: 0, tsc: 1,
      raf: 0, hovering: false, glareEl: null,
    };
    el._dbTilt = state;
    el.classList.add('db-tilt');

    if (o.glare) {
      var gl = document.createElement('span');
      gl.className = 'db-tilt__glare';
      gl.setAttribute('aria-hidden', 'true');
      // блику нужен position:relative у родителя — .db-tilt уже relative
      el.appendChild(gl);
      state.glareEl = gl;
    }

    function render() {
      var s = state, k = s.opts.ease;
      s.rx += (s.trx - s.rx) * k;
      s.ry += (s.try_ - s.ry) * k;
      s.tz += (s.ttz - s.tz) * k;
      s.sc += (s.tsc - s.sc) * k;
      el.style.transform =
        'perspective(' + s.opts.perspective + 'px)' +
        ' rotateX(' + s.rx.toFixed(3) + 'deg)' +
        ' rotateY(' + s.ry.toFixed(3) + 'deg)' +
        ' translateZ(' + s.tz.toFixed(2) + 'px)' +
        ' scale(' + s.sc.toFixed(4) + ')';
      var settled = Math.abs(s.trx - s.rx) < 0.01 && Math.abs(s.try_ - s.ry) < 0.01 &&
                    Math.abs(s.ttz - s.tz) < 0.05 && Math.abs(s.tsc - s.sc) < 0.0005;
      if (!s.hovering && settled) {
        el.style.transform = ''; // полный сброс — не мешаем чужим transform
        el.classList.remove('is-tilting');
        s.raf = 0;
        return;
      }
      s.raf = requestAnimationFrame(render);
    }

    function kick() { if (!state.raf) state.raf = requestAnimationFrame(render); }

    function onMove(ev) {
      if (REDUCED) return;
      var r = el.getBoundingClientRect();
      var px = (ev.clientX - r.left) / r.width * 2 - 1;  // -1..1 (лево..право)
      var py = (ev.clientY - r.top) / r.height * 2 - 1;  // -1..1 (верх..низ)
      px = Math.max(-1, Math.min(1, px));
      py = Math.max(-1, Math.min(1, py));
      var m = state.opts.max;
      if (state.opts.press) {
        // прогиб: точка под курсором уходит вглубь
        state.trx = py * m;        // мышь снизу -> низ отклоняется от зрителя
        state.try_ = -px * m;      // мышь справа -> правый край вглубь
        var dist = Math.min(1, Math.hypot(px, py));
        state.ttz = -state.opts.sink * (1 - dist * 0.4); // в центре давит сильнее
        state.tsc = state.opts.scale;
      } else {
        // классический tilt: угол под курсором тянется к зрителю
        state.trx = -py * m;
        state.try_ = px * m;
        state.ttz = 0;
        state.tsc = 2 - state.opts.scale; // лёгкое увеличение
      }
      if (state.glareEl) {
        state.glareEl.style.setProperty('--gx', ((px + 1) * 50).toFixed(1) + '%');
        state.glareEl.style.setProperty('--gy', ((py + 1) * 50).toFixed(1) + '%');
      }
      state.hovering = true;
      el.classList.add('is-tilting');
      kick();
    }

    function onLeave() {
      state.hovering = false;
      state.trx = 0; state.try_ = 0; state.ttz = 0; state.tsc = 1;
      kick();
    }

    el.addEventListener('pointermove', onMove);
    el.addEventListener('pointerleave', onLeave);
    el.addEventListener('pointerdown', function () {
      // при клике дожимаем сильнее
      state.ttz -= 6; state.tsc -= 0.01; kick();
    });
    el.addEventListener('pointerup', function (ev) { onMove(ev); });

    state.destroy = function () {
      el.removeEventListener('pointermove', onMove);
      el.removeEventListener('pointerleave', onLeave);
      if (state.raf) cancelAnimationFrame(state.raf);
      if (state.glareEl) state.glareEl.remove();
      el.style.transform = '';
      el.classList.remove('is-tilting');
      delete el._dbTilt;
    };
    return state;
  }

  function detach(el) { if (el && el._dbTilt) el._dbTilt.destroy(); }

  /* Автоинициализация: <div data-db-tilt data-db-tilt-max="14" data-db-tilt-press="false"> */
  function init(root) {
    (root || document).querySelectorAll('[data-db-tilt]').forEach(function (el) {
      attach(el, {
        max: parseFloat(el.dataset.dbTiltMax) || undefined,
        press: el.dataset.dbTiltPress !== 'false',
        glare: el.dataset.dbTiltGlare !== 'false',
      });
    });
  }

  g.DulbanTilt = { attach: attach, detach: detach, init: init };
})(typeof window !== 'undefined' ? window : globalThis);
