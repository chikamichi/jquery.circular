###
jQuery Circular Plugin v0.0.5

Release: 19/07/2013
Author: Jean-Denis Vauguet <jd@vauguet.fr>

http://github.com/chikamichi/jquery.circular

Licensed under the MIT licenses: http://www.opensource.org/licenses/mit-license.php
###
((root, factory) ->
  if typeof exports isnt 'undefined'
    # deps. defined as CommonJS exports (for tests)
    module.exports = factory(require('jquery'))
  else
    # deps. fetched from the root object (aka. the browser context)
    factory root.jQuery
) this, ($) ->
  $this = undefined
  _settings =
    aSlide: '.slides .slide'
    aControl: '.controls .control'
    transitionDelay: 1000
    displayDuration: 4000
    startingPoint: 0

  # FIXME: is that actually needed?
  _current = null
  _slides = null
  _controls = null
  _nbSlides = null
  _loop = null

  # Public API.
  methods =
    init: (options) ->
      $this = $(@)
      $.extend _settings, (options or {})
      _current = _settings.startingPoint
      _slides = $(_settings.aSlide, $this)
      _controls = $(_settings.aControl, $this)
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
        $(_settings.aControl, $this).hide()

      $this.trigger('circular:init', [$this])
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
      $this.trigger('circular:paused', [methods.current(), $this])
      return $this

    resume: ->
      _internals.start()
      $this.trigger('circular:resumed', [methods.current(), $this])
      return $this

    # Bind events to this handler to gain support for custom interactions.
    jumpTo: (event, id = null) ->
      id = $(event.currentTarget).data('id') unless id
      prevSlide = methods.current()
      _internals.jumpTo(id)
      $this.trigger('circular:jumped', [methods.current(), prevSlide, $this])
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
      $this.trigger('circular:selected', [methods.current(), $this])

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
        clearInterval(_loop)
        _loop = null
        return true
      else
        return false

    finishAllAnimations: ->
      $.each(_slides, (index, slide) -> $(slide).finish())

    # TODO: refactor this so that it is possible to provide a custom
    # transition effect/logic.
    # Use a custom $.fn.queue
    transitionTo: (to = null, delay = _settings.transitionDelay) ->
      _internals.finishAllAnimations()

      prevSlide = methods.current()
      # FIXME: this assumes the controls are within the slides.
      faded = null
      prevSlide.slide.queue((next) ->
        # TODO: don't call .fadeOut like that
        # use apply to call any custom (with .fadeOut as default) animation
        # function, which MUST return a promise to be resolved once the
        # animation completed.
        faded = $(@).fadeOut(delay).promise()
        next()
      )

      _current = if to != null then to else _internals.next()
      nextSlide = methods.current()
      $this.trigger('circular:fading', [prevSlide, nextSlide, $this])

      faded.done ->
        $this.trigger('circular:faded:out', [nextSlide, prevSlide, $this])
        _internals.setActiveSlide()
        nextSlide.slide.queue((next) ->
          # TODO: don't call .fadeIn like that
          # use apply to call any custom (with .fadeIn as default) animation
          # function, which MUST return a promise to be resolved once the
          # animation completed.
          $(@).fadeIn(delay)
          next()
        )
        $this.trigger('circular:faded', nextSlide, prevSlide, $this)

    bindEvents: ->
      # React upon a control being clicked: switch to its matching slide.
      #
      # It resets the loop, which resumes from the new slide.
      $(_settings.aControl, $this).click methods.jumpTo

    jumpTo: (id) ->
      wasRunning = methods.isRunning()
      _internals.stop() if wasRunning
      _internals.transitionTo(id, 0)
      _internals.start() if wasRunning
      return false

  $.fn.circular = (method) ->
    if method == 'api'
      Object.keys(methods)
    else if methods[method]
      methods[method].apply @, Array::slice.call(arguments, 1)
    else if typeof method is 'object' or not method
      methods.init.apply @, arguments
    else
      $.error 'Method ' + method + ' does not exist on jquery.circular'
