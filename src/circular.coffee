###
jQuery Circular Plugin v0.0.4

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
  _loop = null

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
        _internals.start()
        _internals.bindEvents()
      else
        $(_settings.a_ctl, $this).hide()

      $this.trigger('circular:init', $this)
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
      slide = methods.currentSlide()
      id: slide.data('id')
      slide: slide
      control: methods.currentControl()

    pause: ->
      _internals.stop()
      $this.trigger('circular:paused', methods.current(), $this)
      return $this

    resume: ->
      _internals.start()
      $this.trigger('circular:resumed', methods.current(), $this)
      return $this

    # Bind events to this handler to gain support for custom interactions.
    jumpTo: (event, id = null) ->
      id = $(event.currentTarget).data('id') unless id
      prevSlide = methods.current()
      _internals.jumpTo(id)
      $this.trigger('circular:jumped', methods.current(), prevSlide, $this)
      return $this

    isRunning: ->
      _loop != null

  # Private API.
  _internals =
    # Sets the proper CSS classes on unactive/active slides and controls.
    setActiveSlide: ->
      _controls.removeClass('active')
      methods.currentControl().addClass('active')
      _slides.removeClass('active')
      methods.currentSlide().addClass('active')
      $this.trigger('circular:selected', methods.current(), $this)

    # Returns the next slide's id.
    #
    # This has no side effect. Assign _current flag to actually advance to the
    # next slide.
    next: ->
      if _current + 1 < _nbSlides
        _current + 1
      else
        0

    # Start the animation loop, if not already running.
    #
    # Returns whether the loop started or not.
    start: ->
      if not methods.isRunning()
        _loop = setInterval(_internals.transitionTo
                , _settings.transitionDelay + _settings.displayDuration)
        return true
      else
        return false

    # Stop the animation loop, if currently running.
    #
    # Returns whether the loop stopped or not.
    stop: ->
      if methods.isRunning()
        window.clearInterval(_loop)
        _loop = null
        return true
      else
        return false

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
      wasRunning = methods.isRunning()
      _internals.stop() if wasRunning
      _internals.transitionTo(0, id)
      _internals.start() if wasRunning
      return false

  $.fn.circular = (method) ->
    if methods[method]
      methods[method].apply @, Array::slice.call(arguments, 1)
    else if typeof method is "object" or not method
      methods.init.apply @, arguments
    else
      $.error "Method " + method + " does not exist on jquery.circular"
) jQuery, window, document
