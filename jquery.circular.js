/*
jQuery Circular Plugin v0.0.5

Release: 19/07/2013
Author: Jean-Denis Vauguet <jd@vauguet.fr>

http://github.com/chikamichi/jquery.circular

Licensed under the MIT licenses: http://www.opensource.org/licenses/mit-license.php
*/


(function() {
  (function(root, factory) {
    if (typeof exports !== 'undefined') {
      return module.exports = factory(require('jquery'));
    } else {
      return factory(root.jQuery);
    }
  })(this, function($) {
    var $this, Lifecycle, methods, window, _booted, _controls, _current, _internals, _loop, _nbSlides, _settings, _slides;
    window = this;
    $this = void 0;
    _settings = {
      aSlide: '.slides .slide',
      aControl: '.controls .control',
      transitionDelay: 1000,
      displayDuration: 4000,
      pauseOnHover: false,
      directJump: false,
      startingPoint: 0,
      autoStart: true,
      beforeStart: function(currentSlide, $slides) {}
    };
    _current = null;
    _slides = null;
    _controls = null;
    _nbSlides = null;
    _loop = null;
    _booted = null;
    methods = {
      settings: function() {
        if (_booted) {
          return _settings;
        } else {
          return void 0;
        }
      },
      init: function(options) {
        $this = $(this);
        $.extend(true, _settings, options || {});
        _current = _settings.startingPoint;
        _slides = $(_settings.aSlide, $this);
        _controls = $(_settings.aControl, $this);
        _nbSlides = _slides.size();
        if (_nbSlides > 1) {
          methods.slides().hide();
          _internals.setActiveSlide();
          $(_slides[_current]).fadeIn(_settings.transitionDelay);
          _internals.initLifecycle();
          _internals.bindEvents();
          methods.pause();
          _settings.beforeStart.call($this, methods.current(), methods.slides());
          if (_settings.autoStart) {
            _internals.resume();
          }
        } else {
          $(_settings.aControl, $this).hide();
        }
        _booted = true;
        $this.trigger('circular:init', [$this]);
        return $this;
      },
      currentSlide: function() {
        return $(_slides[_current]);
      },
      currentControl: function() {
        return $(_controls[_current]);
      },
      current: function() {
        var slide;
        slide = methods.currentSlide();
        return {
          id: slide.data('id'),
          slide: slide,
          control: methods.currentControl()
        };
      },
      slides: function() {
        return $(_slides);
      },
      controls: function() {
        return $(_controls);
      },
      pause: function() {
        _internals.pause();
        $this.trigger('circular:paused', [methods.current(), $this]);
        return $this;
      },
      resume: function() {
        _internals.resume();
        $this.trigger('circular:resumed', [methods.current(), $this]);
        return $this;
      },
      jumpTo: function(event, id) {
        var prevSlide;
        if (id == null) {
          id = null;
        }
        if (!id) {
          id = $(event.currentTarget).data('id');
        }
        prevSlide = methods.current();
        _internals.jumpTo(id);
        $this.trigger('circular:jumped', [methods.current(), prevSlide, $this]);
        return $this;
      },
      isAlive: function() {
        return !!_booted;
      },
      isRunning: function() {
        if (!_loop) {
          return false;
        }
        return !_loop.isPaused();
      }
    };
    _internals = {
      setActiveSlide: function() {
        _controls.removeClass('active');
        methods.currentControl().addClass('active');
        _slides.removeClass('active');
        methods.currentSlide().addClass('active');
        return $this.trigger('circular:selected', [methods.current(), $this]);
      },
      next: function() {
        if (_current + 1 < _nbSlides) {
          return _current + 1;
        } else {
          return 0;
        }
      },
      initLifecycle: function() {
        if (_loop) {
          return;
        }
        return _loop = new Lifecycle(_internals.transitionTo, _settings.transitionDelay + _settings.displayDuration);
      },
      resume: function() {
        if (!methods.isRunning()) {
          _loop.resume();
          return true;
        } else {
          return false;
        }
      },
      pause: function() {
        if (methods.isRunning()) {
          _loop.pause();
          return true;
        } else {
          return false;
        }
      },
      finishAllAnimations: function() {
        return $.each(_slides, function(index, slide) {
          return $(slide).finish();
        });
      },
      effects: {
        out: function(delay) {
          var _ref;
          return ((_ref = _settings.effects) != null ? _ref.out.apply(this, arguments) : void 0) || $.fn.fadeOut;
        },
        "in": function(delay) {
          var _ref;
          return ((_ref = _settings.effects) != null ? _ref["in"].apply(this, arguments) : void 0) || $.fn.fadeIn;
        }
      },
      transitionTo: function(to, delay) {
        var faded, nextSlide, prevSlide;
        if (to == null) {
          to = null;
        }
        if (delay == null) {
          delay = _settings.transitionDelay;
        }
        _internals.finishAllAnimations();
        prevSlide = methods.current();
        faded = null;
        prevSlide.slide.queue(function(next) {
          var effect;
          effect = _internals.effects.out.call(this, delay);
          faded = effect.call($(this), delay).promise();
          return next();
        });
        _current = to !== null ? to : _internals.next();
        nextSlide = methods.current();
        $this.trigger('circular:fading', [prevSlide, nextSlide, $this]);
        return faded.done(function() {
          $this.trigger('circular:faded:out', [nextSlide, prevSlide, $this]);
          _internals.setActiveSlide();
          return nextSlide.slide.queue(function(next) {
            var effect;
            effect = _internals.effects["in"].call(this, delay);
            effect.call($(this), delay).promise().done(function() {
              return $this.trigger('circular:faded:in', [nextSlide, prevSlide, $this]);
            });
            return next();
          });
        });
      },
      bindEvents: function() {
        var pause, resume;
        $(_settings.aControl, $this).click(methods.jumpTo);
        if (_settings.pauseOnHover) {
          pause = methods.pause;
          resume = methods.resume;
          return $this.hover(pause, resume);
        }
      },
      jumpTo: function(id) {
        var current, delay, wasRunning;
        current = methods.current();
        if (id === current.id) {
          $this.trigger('circular:toSelf', [current, $this]);
          return;
        }
        wasRunning = methods.isRunning();
        delay = _settings.directJump ? 0 : null;
        if (wasRunning) {
          _internals.pause();
        }
        _internals.transitionTo(id, delay);
        if (wasRunning) {
          _internals.resume();
        }
        return false;
      }
    };
    Lifecycle = function(callback, delay) {
      var isPaused, paused, remaining, resume, start, timerId;
      timerId = void 0;
      start = void 0;
      paused = true;
      remaining = delay;
      this.pause = function() {
        clearTimeout(timerId);
        paused = true;
        return remaining -= new Date() - start;
      };
      resume = function() {
        start = new Date();
        paused = false;
        return timerId = setTimeout(function() {
          remaining = delay;
          resume();
          return callback();
        }, remaining);
      };
      isPaused = function() {
        return !!paused;
      };
      this.isPaused = isPaused;
      this.resume = resume;
      return this;
    };
    $.fn.circular = function(method) {
      if (!$.fn.circular.test) {
        $.fn.circular["private"] = void 0;
      }
      if (method === 'api') {
        return Object.keys(methods);
      } else if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      } else {
        return $.error('Method ' + method + ' does not exist on jquery.circular');
      }
    };
    $.fn.circular["public"] = methods;
    return $.fn.circular["private"] = _internals;
  });

}).call(this);
