/* ============================================================
   DULBAN LIB · dulban-easings.js
   Функции плавности (Robert Penner easings) для JS-анимаций.
   Экспорт: window.DulbanEase
   Каждая функция: t ∈ [0..1] → прогресс [0..1] (back/elastic могут выходить за пределы).
   Tampermonkey: // @require .../js/dulban-easings.js
   ============================================================ */
(function (g) {
  'use strict';

  var PI = Math.PI;
  var c1 = 1.70158;
  var c2 = c1 * 1.525;
  var c3 = c1 + 1;
  var c4 = (2 * PI) / 3;
  var c5 = (2 * PI) / 4.5;

  function bounceOut(t) {
    var n1 = 7.5625, d1 = 2.75;
    if (t < 1 / d1) return n1 * t * t;
    if (t < 2 / d1) { t -= 1.5 / d1; return n1 * t * t + 0.75; }
    if (t < 2.5 / d1) { t -= 2.25 / d1; return n1 * t * t + 0.9375; }
    t -= 2.625 / d1; return n1 * t * t + 0.984375;
  }

  var E = {
    linear: function (t) { return t; },

    inSine: function (t) { return 1 - Math.cos((t * PI) / 2); },
    outSine: function (t) { return Math.sin((t * PI) / 2); },
    inOutSine: function (t) { return -(Math.cos(PI * t) - 1) / 2; },

    inQuad: function (t) { return t * t; },
    outQuad: function (t) { return 1 - (1 - t) * (1 - t); },
    inOutQuad: function (t) { return t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2; },

    inCubic: function (t) { return t * t * t; },
    outCubic: function (t) { return 1 - Math.pow(1 - t, 3); },
    inOutCubic: function (t) { return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; },

    inQuart: function (t) { return t * t * t * t; },
    outQuart: function (t) { return 1 - Math.pow(1 - t, 4); },
    inOutQuart: function (t) { return t < 0.5 ? 8 * t * t * t * t : 1 - Math.pow(-2 * t + 2, 4) / 2; },

    inQuint: function (t) { return t * t * t * t * t; },
    outQuint: function (t) { return 1 - Math.pow(1 - t, 5); },
    inOutQuint: function (t) { return t < 0.5 ? 16 * t * t * t * t * t : 1 - Math.pow(-2 * t + 2, 5) / 2; },

    inExpo: function (t) { return t === 0 ? 0 : Math.pow(2, 10 * t - 10); },
    outExpo: function (t) { return t === 1 ? 1 : 1 - Math.pow(2, -10 * t); },
    inOutExpo: function (t) {
      if (t === 0 || t === 1) return t;
      return t < 0.5 ? Math.pow(2, 20 * t - 10) / 2 : (2 - Math.pow(2, -20 * t + 10)) / 2;
    },

    inCirc: function (t) { return 1 - Math.sqrt(1 - t * t); },
    outCirc: function (t) { return Math.sqrt(1 - Math.pow(t - 1, 2)); },
    inOutCirc: function (t) {
      return t < 0.5
        ? (1 - Math.sqrt(1 - Math.pow(2 * t, 2))) / 2
        : (Math.sqrt(1 - Math.pow(-2 * t + 2, 2)) + 1) / 2;
    },

    inBack: function (t) { return c3 * t * t * t - c1 * t * t; },
    outBack: function (t) { return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2); },
    inOutBack: function (t) {
      return t < 0.5
        ? (Math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2
        : (Math.pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2;
    },

    inElastic: function (t) {
      if (t === 0 || t === 1) return t;
      return -Math.pow(2, 10 * t - 10) * Math.sin((t * 10 - 10.75) * c4);
    },
    outElastic: function (t) {
      if (t === 0 || t === 1) return t;
      return Math.pow(2, -10 * t) * Math.sin((t * 10 - 0.75) * c4) + 1;
    },
    inOutElastic: function (t) {
      if (t === 0 || t === 1) return t;
      return t < 0.5
        ? -(Math.pow(2, 20 * t - 10) * Math.sin((20 * t - 11.125) * c5)) / 2
        : (Math.pow(2, -20 * t + 10) * Math.sin((20 * t - 11.125) * c5)) / 2 + 1;
    },

    inBounce: function (t) { return 1 - bounceOut(1 - t); },
    outBounce: bounceOut,
    inOutBounce: function (t) {
      return t < 0.5 ? (1 - bounceOut(1 - 2 * t)) / 2 : (1 + bounceOut(2 * t - 1)) / 2;
    },
  };

  /* CSS-эквиваленты (для transition/animation-timing-function) */
  E.css = {
    linear: 'linear',
    inSine: 'cubic-bezier(.12,0,.39,0)', outSine: 'cubic-bezier(.61,1,.88,1)', inOutSine: 'cubic-bezier(.37,0,.63,1)',
    inQuad: 'cubic-bezier(.11,0,.5,0)', outQuad: 'cubic-bezier(.5,1,.89,1)', inOutQuad: 'cubic-bezier(.45,0,.55,1)',
    inCubic: 'cubic-bezier(.32,0,.67,0)', outCubic: 'cubic-bezier(.33,1,.68,1)', inOutCubic: 'cubic-bezier(.65,0,.35,1)',
    inQuart: 'cubic-bezier(.5,0,.75,0)', outQuart: 'cubic-bezier(.25,1,.5,1)', inOutQuart: 'cubic-bezier(.76,0,.24,1)',
    inQuint: 'cubic-bezier(.64,0,.78,0)', outQuint: 'cubic-bezier(.22,1,.36,1)', inOutQuint: 'cubic-bezier(.83,0,.17,1)',
    inExpo: 'cubic-bezier(.7,0,.84,0)', outExpo: 'cubic-bezier(.16,1,.3,1)', inOutExpo: 'cubic-bezier(.87,0,.13,1)',
    inCirc: 'cubic-bezier(.55,0,1,.45)', outCirc: 'cubic-bezier(0,.55,.45,1)', inOutCirc: 'cubic-bezier(.85,0,.15,1)',
    inBack: 'cubic-bezier(.36,0,.66,-.56)', outBack: 'cubic-bezier(.34,1.56,.64,1)', inOutBack: 'cubic-bezier(.68,-.6,.32,1.6)',
  };

  /* Получить функцию по имени с фолбэком */
  E.get = function (name) {
    if (typeof name === 'function') return name;
    return E[name] || E.outCubic;
  };

  g.DulbanEase = E;
})(typeof window !== 'undefined' ? window : globalThis);
