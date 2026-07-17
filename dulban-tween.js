/* ============================================================
   DULBAN LIB · dulban-tween.js
   Мини-движок tweening-анимаций в духе After Effects.
   Экспорт: window.DulbanTween
   Зависимость: dulban-easings.js (window.DulbanEase)

   Возможности:
   - DulbanTween.to(el|els|selector|obj, opts) — твин свойств
   - transform-шорткаты: x, y, scale, scaleX, scaleY, rotate, rotateX, rotateY, skewX
   - style-свойства: opacity и любые числовые (width, height, left...)
   - значения: 120 | [from, to] | '120px'
   - stagger, repeat, yoyo, onStart/onUpdate/onComplete
   - DulbanTween.keyframes(el, {prop, frames:[{t,v,ease}...]}) — ключевые кадры как в AE
   - DulbanTween.timeline().add(...).add(..., '-=200').play() — таймлайн с оффсетами
   - твин простых объектов: DulbanTween.to({p:0},{p:1,onUpdate:...})
   ============================================================ */
(function (g) {
  'use strict';

  var Ease = (g.DulbanEase && g.DulbanEase.get) ? g.DulbanEase : { get: function () { return function (t) { return t; }; } };

  var TRANSFORM_KEYS = { x: 'px', y: 'px', z: 'px', rotate: 'deg', rotateX: 'deg', rotateY: 'deg', skewX: 'deg', skewY: 'deg', scale: '', scaleX: '', scaleY: '' };
  var UNITLESS_STYLES = { opacity: 1, zIndex: 1 };
  var RESERVED = { duration: 1, delay: 1, ease: 1, repeat: 1, yoyo: 1, stagger: 1, onStart: 1, onUpdate: 1, onComplete: 1 };

  var active = [];
  var rafId = null;

  function now() { return performance.now(); }

  function loop() {
    var t = now();
    for (var i = active.length - 1; i >= 0; i--) {
      if (step(active[i], t)) active.splice(i, 1);
    }
    rafId = active.length ? requestAnimationFrame(loop) : null;
  }
  function kick() { if (!rafId) rafId = requestAnimationFrame(loop); }

  /* --- transform-состояние на элементе --------------------------- */
  function tstate(el) {
    if (!el._dbTw) el._dbTw = { x: 0, y: 0, z: 0, rotate: 0, rotateX: 0, rotateY: 0, skewX: 0, skewY: 0, scale: 1, scaleX: 1, scaleY: 1 };
    return el._dbTw;
  }
  function buildTransform(s) {
    var out = '';
    if (s.x || s.y || s.z) out += 'translate3d(' + s.x + 'px,' + s.y + 'px,' + s.z + 'px)';
    if (s.rotate) out += ' rotate(' + s.rotate + 'deg)';
    if (s.rotateX) out += ' rotateX(' + s.rotateX + 'deg)';
    if (s.rotateY) out += ' rotateY(' + s.rotateY + 'deg)';
    if (s.skewX) out += ' skewX(' + s.skewX + 'deg)';
    if (s.skewY) out += ' skewY(' + s.skewY + 'deg)';
    if (s.scale !== 1) out += ' scale(' + s.scale + ')';
    if (s.scaleX !== 1) out += ' scaleX(' + s.scaleX + ')';
    if (s.scaleY !== 1) out += ' scaleY(' + s.scaleY + ')';
    return out.trim();
  }

  function parseVal(v) {
    // '120px' -> {n:120, u:'px'}; 120 -> {n:120, u:null}
    if (typeof v === 'number') return { n: v, u: null };
    var m = /^(-?\d*\.?\d+)([a-z%]*)$/i.exec(String(v).trim());
    return m ? { n: parseFloat(m[1]), u: m[2] || null } : { n: 0, u: null };
  }

  function currentValue(target, key) {
    if (!(target instanceof Element)) return typeof target[key] === 'number' ? target[key] : 0;
    if (key in TRANSFORM_KEYS) return tstate(target)[key];
    var cs = g.getComputedStyle(target)[key];
    var p = parseVal(cs);
    return isNaN(p.n) ? 0 : p.n;
  }

  function applyValue(target, key, val, unit) {
    if (!(target instanceof Element)) { target[key] = val; return; }
    if (key in TRANSFORM_KEYS) {
      var s = tstate(target);
      s[key] = val;
      target.style.transform = buildTransform(s);
      return;
    }
    var u = unit != null ? unit : (UNITLESS_STYLES[key] ? '' : 'px');
    target.style[key] = val + u;
  }

  /* --- один твин ---------------------------------------------- */
  function makeTween(target, opts, extraDelay) {
    var props = [];
    Object.keys(opts).forEach(function (key) {
      if (RESERVED[key]) return;
      var v = opts[key], from, to, unit = null;
      if (Array.isArray(v)) {
        var pf = parseVal(v[0]), pt = parseVal(v[1]);
        from = pf.n; to = pt.n; unit = pt.u || pf.u;
      } else {
        var p = parseVal(v);
        from = null; to = p.n; unit = p.u; // from возьмём при старте
      }
      props.push({ key: key, from: from, to: to, unit: unit });
    });
    return {
      target: target,
      props: props,
      duration: Math.max(1, opts.duration != null ? opts.duration : 600),
      delay: (opts.delay || 0) + (extraDelay || 0),
      ease: Ease.get(opts.ease),
      repeat: opts.repeat || 0,
      yoyo: !!opts.yoyo,
      onStart: opts.onStart, onUpdate: opts.onUpdate, onComplete: opts.onComplete,
      startTime: null, started: false, cycle: 0,
      resolve: null,
    };
  }

  function step(tw, t) {
    if (tw.startTime === null) tw.startTime = t + tw.delay;
    if (t < tw.startTime) return false;
    if (!tw.started) {
      tw.started = true;
      tw.props.forEach(function (p) { if (p.from === null) p.from = currentValue(tw.target, p.key); });
      if (tw.onStart) tw.onStart(tw.target);
    }
    var raw = Math.min(1, (t - tw.startTime) / tw.duration);
    var flip = tw.yoyo && (tw.cycle % 2 === 1);
    var e = tw.ease(flip ? 1 - raw : raw);
    tw.props.forEach(function (p) {
      applyValue(tw.target, p.key, p.from + (p.to - p.from) * e, p.unit);
    });
    if (tw.onUpdate) tw.onUpdate(raw, tw.target);
    if (raw >= 1) {
      if (tw.cycle < tw.repeat) { tw.cycle++; tw.startTime = t; return false; }
      if (tw.onComplete) tw.onComplete(tw.target);
      if (tw.resolve) tw.resolve(tw.target);
      return true;
    }
    return false;
  }

  function resolveTargets(targets) {
    if (typeof targets === 'string') return Array.prototype.slice.call(document.querySelectorAll(targets));
    if (targets instanceof Element || typeof targets === 'object' && !Array.isArray(targets) && !(targets instanceof NodeList)) {
      return targets instanceof NodeList ? Array.prototype.slice.call(targets) : [targets];
    }
    return Array.prototype.slice.call(targets);
  }

  /* --- API --------------------------------------------------------- */
  var DulbanTween = {
    /** Твин к значениям. Возвращает Promise (резолв по завершению всех целей). */
    to: function (targets, opts) {
      var els = resolveTargets(targets);
      var stagger = opts.stagger || 0;
      var promises = els.map(function (el, i) {
        var tw = makeTween(el, opts, i * stagger);
        active.push(tw);
        return new Promise(function (res) { tw.resolve = res; });
      });
      kick();
      return Promise.all(promises);
    },

    /** Ключевые кадры как в After Effects: каждый сегмент со своей кривой.
     *  frames: [{ t:0, v:0 }, { t:0.4, v:200, ease:'outCubic' }, { t:1, v:80, ease:'inOutQuad' }]
     *  t — доля длительности [0..1], v — значение, ease — кривая ПОДХОДА к этому кадру. */
    keyframes: function (target, cfg) {
      var els = resolveTargets(target);
      var frames = cfg.frames.slice().sort(function (a, b) { return a.t - b.t; });
      var duration = cfg.duration || 1000;
      var prop = cfg.prop;
      var unit = cfg.unit != null ? cfg.unit : null;
      var promises = els.map(function (el) {
        return DulbanTween.to({ p: 0 }, {
          p: 1, duration: duration, delay: cfg.delay || 0, ease: 'linear',
          onUpdate: function (raw) {
            // найти текущий сегмент
            var a = frames[0], b = frames[frames.length - 1];
            for (var i = 1; i < frames.length; i++) {
              if (raw <= frames[i].t) { a = frames[i - 1]; b = frames[i]; break; }
              a = frames[i - 1]; b = frames[i];
            }
            var span = Math.max(1e-6, b.t - a.t);
            var local = Math.min(1, Math.max(0, (raw - a.t) / span));
            var e = Ease.get(b.ease)(local);
            applyValue(el, prop, a.v + (b.v - a.v) * e, unit);
            if (cfg.onUpdate) cfg.onUpdate(raw, el);
          },
          onComplete: cfg.onComplete,
        });
      });
      return Promise.all(promises);
    },

    /** Таймлайн: последовательность твинов с оффсетами ('-=200' / '+=100' / число-ms). */
    timeline: function () {
      var entries = [];
      var cursor = 0;
      var tl = {
        add: function (targets, opts, offset) {
          var at = cursor;
          if (typeof offset === 'string') {
            var d = parseFloat(offset.slice(2)) || 0;
            at = offset[0] === '-' ? cursor - d : cursor + d;
          } else if (typeof offset === 'number') {
            at = offset;
          }
          var dur = (opts.duration != null ? opts.duration : 600) + (opts.delay || 0) +
                    (opts.stagger ? opts.stagger * (resolveTargets(targets).length - 1) : 0);
          entries.push({ targets: targets, opts: opts, at: Math.max(0, at) });
          cursor = Math.max(cursor, Math.max(0, at) + dur);
          return tl;
        },
        play: function () {
          return Promise.all(entries.map(function (e) {
            var o = Object.assign({}, e.opts);
            o.delay = (o.delay || 0) + e.at;
            return DulbanTween.to(e.targets, o);
          }));
        },
        duration: function () { return cursor; },
      };
      return tl;
    },

    /** Снять все твины с цели */
    kill: function (target) {
      for (var i = active.length - 1; i >= 0; i--) {
        if (active[i].target === target) active.splice(i, 1);
      }
    },
  };

  g.DulbanTween = DulbanTween;
})(typeof window !== 'undefined' ? window : globalThis);
