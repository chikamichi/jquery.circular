/*
jQuery Circular Plugin v0.1

Release: 06/07/2013
Author: Jean-Denis Vauguet <jd@vauguet.fr>

http://github.com/chikamichi/jquery.circular

Licensed under the MIT licenses: http://www.opensource.org/licenses/mit-license.php
*/


(function() {
  (function($, window, document) {
    var $this, methods, _current, _internals, _interval, _nbSlides, _settings, _slides;
    $this = void 0;
    _settings = {
      a_slide: ".slides .slide",
      a_ctl: ".controls .control",
      transitionDelay: 1000,
      displayDuration: 4000,
      startingPoint: 0
    };
    _current = _settings.startingPoint;
    _slides = null;
    _nbSlides = null;
    _interval = null;
    methods = {
      init: function(options) {
        $this = $(this);
        $.extend(_settings, options || {});
        _slides = $(_settings.a_slide, $this);
        _nbSlides = _slides.size();
        if (_nbSlides > 1) {
          $(_slides).hide();
          _internals.setActiveSlide();
          $(_slides[_current]).fadeIn(_settings.transitionDelay);
          _interval = _internals.start();
          _internals.bindEvents();
        } else {
          $(_settings.a_ctl, $this).hide();
        }
        return $this;
      }
    };
    _internals = {
      setActiveSlide: function() {
        var id;
        id = _current + 1;
        $(_settings.a_ctl, $this).removeClass('active');
        $(_settings.a_ctl + ("[data-id=" + id + "]"), $this).addClass('active');
        $(_settings.a_slide, $this).removeClass('active');
        return $(_settings.a_slide + ("[data-id=" + id + "]"), $this).addClass('active');
      },
      next: function() {
        if (_current + 1 < _nbSlides) {
          return _current + 1;
        } else {
          return 0;
        }
      },
      start: function() {
        return setInterval(function() {
          var faded;
          faded = $(_slides[_current]).fadeOut(_settings.transitionDelay).promise();
          _current = _internals.next();
          return faded.done(function() {
            _internals.setActiveSlide();
            return $(_slides[_current]).fadeIn(_settings.transitionDelay);
          });
        }, _settings.transitionDelay + _settings.displayDuration);
      },
      bindEvents: function() {
        return $(_settings.a_ctl, $this).click(function(e) {
          var selected;
          selected = $(this).data("id") - 1;
          window.clearInterval(_interval);
          $(_slides[_current]).hide();
          _current = selected;
          _internals.setActiveSlide();
          $(_slides[selected]).show();
          _interval = _internals.start();
          return false;
        });
      }
    };
    return $.fn.circular = function(method) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === "object" || !method) {
        return methods.init.apply(this, arguments);
      } else {
        return $.error("Method " + method + " does not exist on jquery.circular");
      }
    };
  })(jQuery, window, document);

}).call(this);
