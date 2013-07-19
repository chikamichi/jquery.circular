###
jQuery Circular Plugin v0.3

Release: 19/07/2013
Author: Jean-Denis Vauguet <jd@vauguet.fr>

http://github.com/chikamichi/jquery.circular

Licensed under the MIT licenses: http://www.opensource.org/licenses/mit-license.php
###
(($, window, document) ->
  $this = undefined
  _settings =
    a_slide: ".slides .slide"
    a_ctl: ".controls .control"
    transitionDelay: 1000
    displayDuration: 4000
    startingPoint: 0

  _current = _settings.startingPoint
  _slides = null
  _controls = null
  _nbSlides = null
  _interval = null

  # Public API.
  methods =
    init: (options) ->
      $this = $(@)
      $.extend _settings, (options or {})
      _slides = $(_settings.a_slide, $this)
      _controls = $(_settings.a_ctl, $this)
      _nbSlides = _slides.size()

      # Let's go…
      if _nbSlides > 1
        # Set the first slide right.
        $(_slides).hide()
        _internals.setActiveSlide()
        $(_slides[_current]).fadeIn(_settings.transitionDelay)
        # Init the loop.
        _interval = _internals.start()
        _internals.bindEvents()
      else
        $(_settings.a_ctl, $this).hide()

      return $this

    # Returns the current slide's DOM element.
    currentSlide: ->
      $(_slides[_current])

    # Returns the current slide's control (DOM element).
    currentControl: ->
      $(_controls[_current])

    # Returns an object with slide and control properties for the current
    # slide.
    current: ->
      slide: methods.currentSlide()
      control: methods.currentControl()

    # Bind events to this handler to gain support for custom interactions.
    jumpTo: (event, id = null) ->
      id = $(event.currentTarget).data('id') unless id
      _internals.jumpTo(id)

  # Private API.
  _internals =
    # Set proper CSS classes on unactive/active slides and controls.
    setActiveSlide: ->
      _controls.removeClass('active')
      methods.currentControl().addClass('active')
      _slides.removeClass('active')
      methods.currentSlide().addClass('active')
      $this.trigger('circular:selected', methods.current(), $this)

    next: ->
      if _current + 1 < _nbSlides
        _current + 1
      else
        0

    # Looping.
    #
    # Call this to reinit the carousel from the current starting point.
    start: ->
      setInterval(_internals.transitionTo
      , _settings.transitionDelay + _settings.displayDuration)

    # TODO: refactor this so that it is possible to provide a custom
    # transition effect/logic.
    transitionTo: (delay = _settings.transitionDelay, to = null) ->
      prevSlide = methods.current()
      # FIXME: this assumes the controls are within the slides.
      faded = prevSlide.slide.fadeOut(delay).promise()

      _current = if to != null then to else _internals.next()
      nextSlide = methods.current()

      $this.trigger('circular:fading', prevSlide, nextSlide, $this)

      faded.done ->
        _internals.setActiveSlide()
        nextSlide.slide.fadeIn(delay)
        $this.trigger('circular:faded', nextSlide, prevSlide, $this)

    bindEvents: ->
      # React upon a control being clicked: switch to its matching slide, reset
      # the loop.
      $(_settings.a_ctl, $this).click methods.jumpTo

    jumpTo: (id) ->
      window.clearInterval(_interval)
      _internals.transitionTo(0, id)
      _interval = _internals.start()
      return false

  $.fn.circular = (method) ->
    if methods[method]
      methods[method].apply @, Array::slice.call(arguments, 1)
    else if typeof method is "object" or not method
      methods.init.apply @, arguments
    else
      $.error "Method " + method + " does not exist on jquery.circular"
) jQuery, window, document
