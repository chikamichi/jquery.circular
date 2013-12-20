/*
jQuery Circular Plugin v0.0.5

Release: 19/07/2013
Author: Jean-Denis Vauguet <jd@vauguet.fr>

http://github.com/chikamichi/jquery.circular

Licensed under the MIT licenses: http://www.opensource.org/licenses/mit-license.php
*/


(function() {
  (function(root, factory) {
    var document, jsdom, window;
    if (typeof exports !== 'undefined') {
      jsdom = require('jsdom');
      document = jsdom.jsdom('<html><head></head><body>hello world</body></html>');
      window = document.parentWindow;
      return module.exports = factory(require('jquery'), document, window);
    } else {
      return factory(root.jQuery, root.document, root.window);
    }
  })(this, function($, document, window) {
    var $this, methods, _controls, _current, _internals, _loop, _nbSlides, _settings, _slides;
    $this = void 0;
    _settings = {
      aSlide: '.slides .slide',
      aControl: '.controls .control',
      transitionDelay: 1000,
      displayDuration: 4000,
      startingPoint: 0
    };
    _current = null;
    _slides = null;
    _controls = null;
    _nbSlides = null;
    _loop = null;
    methods = {
      init: function(options) {
        $this = $(this);
        $.extend(_settings, options || {});
        _current = _settings.startingPoint;
        _slides = $(_settings.aSlide, $this);
        _controls = $(_settings.aControl, $this);
        _nbSlides = _slides.size();
        if (_nbSlides > 1) {
          $(_slides).hide();
          _internals.setActiveSlide();
          $(_slides[_current]).fadeIn(_settings.transitionDelay);
          _internals.start();
          _internals.bindEvents();
        } else {
          $(_settings.aControl, $this).hide();
        }
        $this.trigger('circular:init', $this);
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
      pause: function() {
        _internals.stop();
        $this.trigger('circular:paused', methods.current(), $this);
        return $this;
      },
      resume: function() {
        _internals.start();
        $this.trigger('circular:resumed', methods.current(), $this);
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
        $this.trigger('circular:jumped', methods.current(), prevSlide, $this);
        return $this;
      },
      isRunning: function() {
        return _loop !== null;
      }
    };
    _internals = {
      setActiveSlide: function() {
        _controls.removeClass('active');
        methods.currentControl().addClass('active');
        _slides.removeClass('active');
        methods.currentSlide().addClass('active');
        return $this.trigger('circular:selected', methods.current(), $this);
      },
      next: function() {
        if (_current + 1 < _nbSlides) {
          return _current + 1;
        } else {
          return 0;
        }
      },
      start: function() {
        if (!methods.isRunning()) {
          _loop = setInterval(_internals.transitionTo, _settings.transitionDelay + _settings.displayDuration);
          return true;
        } else {
          return false;
        }
      },
      stop: function() {
        if (methods.isRunning()) {
          window.clearInterval(_loop);
          _loop = null;
          return true;
        } else {
          return false;
        }
      },
      transitionTo: function(delay, to) {
        var faded, nextSlide, prevSlide;
        if (delay == null) {
          delay = _settings.transitionDelay;
        }
        if (to == null) {
          to = null;
        }
        prevSlide = methods.current();
        faded = prevSlide.slide.fadeOut(delay).promise();
        _current = to !== null ? to : _internals.next();
        nextSlide = methods.current();
        $this.trigger('circular:fading', prevSlide, nextSlide, $this);
        return faded.done(function() {
          _internals.setActiveSlide();
          nextSlide.slide.fadeIn(delay);
          return $this.trigger('circular:faded', nextSlide, prevSlide, $this);
        });
      },
      bindEvents: function() {
        return $(_settings.aControl, $this).click(methods.jumpTo);
      },
      jumpTo: function(id) {
        var wasRunning;
        wasRunning = methods.isRunning();
        if (wasRunning) {
          _internals.stop();
        }
        _internals.transitionTo(0, id);
        if (wasRunning) {
          _internals.start();
        }
        return false;
      }
    };
    return $.fn.circular = function(method) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      } else {
        return $.error('Method ' + method + ' does not exist on jquery.circular');
      }
    };
  });

}).call(this);
