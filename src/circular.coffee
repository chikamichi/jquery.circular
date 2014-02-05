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
  window = @
  $this = undefined
  _settings =
    aSlide: '.slides .slide'
    aControl: '.controls .control'
    transitionDelay: 1000
    displayDuration: 4000
    pauseOnHover: false
    directJump: false
    startingPoint: 0
    autoStart: true
    beforeStart: (currentSlide, $slides) ->

  # FIXME: is that actually needed?
  _current = null
  _slides = null
  _controls = null
  _nbSlides = null
  _loop = null
  _booted = null

  # Public API.
  methods =
    init: (options) ->
      $this = $(@)
      $.extend true, _settings, (options or {})
      _current = _settings.startingPoint
      _slides = $(_settings.aSlide, $this)
      _controls = $(_settings.aControl, $this)
      _nbSlides = _slides.size()

      # Let's go…
      if _nbSlides > 1
        # Set the first slide right.
        methods.slides().hide()
        _internals.setActiveSlide()
        $(_slides[_current]).fadeIn(_settings.transitionDelay)
        # Init the loop.
        _internals.initLifecycle()
        _internals.bindEvents()
        methods.pause()
        # Let's party.
        _settings.beforeStart.call($this, methods.current(), methods.slides())
        _internals.resume() if _settings.autoStart
      else
        $(_settings.aControl, $this).hide()

      _booted = true
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

    slides: ->
      $(_slides)

    controls: ->
      $(_controls)

    pause: ->
      _internals.pause()
      $this.trigger('circular:paused', [methods.current(), $this])
      return $this

    resume: ->
      _internals.resume()
      $this.trigger('circular:resumed', [methods.current(), $this])
      return $this

    # Bind events to this handler to gain support for custom interactions.
    jumpTo: (event, id = null) ->
      id = $(event.currentTarget).data('id') unless id
      prevSlide = methods.current()
      _internals.jumpTo(id)
      $this.trigger('circular:jumped', [methods.current(), prevSlide, $this])
      return $this

    # Has a legacy carousel spawned?
    #
    # When there is no slide or only one, it returns false.
    isAlive: ->
      !!_booted

    # Is the carousel running?
    #
    # When the carousel has been paused, or did not start, it returns false.
    isRunning: ->
      return false if !_loop
      !_loop.isPaused()

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

    initLifecycle: ->
      return if _loop
      _loop = new Lifecycle(
        _internals.transitionTo,
          _settings.transitionDelay + _settings.displayDuration)

    # Start the animation loop, if not already running.
    #
    # Returns whether the loop started or not.
    resume: ->
      if not methods.isRunning()
        _loop.resume()
        return true
      else
        return false

    # pause the animation loop, if currently running.
    #
    # Returns whether the loop pauseped or not.
    pause: ->
      if methods.isRunning()
        _loop.pause()
        return true
      else
        return false

    finishAllAnimations: ->
      # FIXME: do this only if an animation is ongoing
      $.each(_slides, (index, slide) -> $(slide).finish())

    # TODO: it could prove useful to pass the animated slide descriptor?
    effects:
      out: (delay) -> _settings.effects?.out.apply(@, arguments) or $.fn.fadeOut
      in: (delay) -> _settings.effects?.in.apply(@, arguments) or $.fn.fadeIn

    transitionTo: (to = null, delay) ->
      delay ?= _settings.transitionDelay
      _internals.finishAllAnimations()

      prevSlide = methods.current()
      # FIXME: this assumes the controls are within the slides.
      faded = null
      prevSlide.slide.queue((next) ->
        effect = _internals.effects.out.call(@, delay)
        faded = effect.call($(@), delay).promise()
        next()
      )

      _current = if to != null then to else _internals.next()
      nextSlide = methods.current()
      $this.trigger('circular:fading', [prevSlide, nextSlide, $this])

      faded.done ->
        $this.trigger('circular:faded:out', [nextSlide, prevSlide, $this])
        _internals.setActiveSlide()
        nextSlide.slide.queue((next) ->
          effect = _internals.effects.in.call(@, delay)
          effect.call($(@), delay).promise().done ->
            $this.trigger('circular:faded:in', [nextSlide, prevSlide, $this])
          next()
        )

    bindEvents: ->
      # React upon a control being clicked: switch to its matching slide.
      # It resets the loop, which resumes from the new slide.
      $(_settings.aControl, $this).click methods.jumpTo

      # If the settings command it, let's pause on hover.
      if _settings.pauseOnHover
        pause = methods.pause
        resume = methods.resume
        $this.hover(pause, resume)

    jumpTo: (id) ->
      current = methods.current()
      if id == current.id
        $this.trigger('circular:toSelf', [current, $this])
        return
      wasRunning = methods.isRunning()
      delay = if _settings.directJump then 0 else null
      _internals.pause() if wasRunning
      _internals.transitionTo(id, delay)
      _internals.resume() if wasRunning
      return false

  # Carousel's lifecycle is handled by this object.
  #
  # Simple wrapper around a setTimeout to handle pause/resume.
  Lifecycle = (callback, delay) ->
    timerId = undefined
    start = undefined
    paused = true
    remaining = delay

    @pause = ->
      clearTimeout timerId
      paused = true
      remaining -= new Date() - start

    resume = ->
      start = new Date()
      paused = false
      timerId = setTimeout(->
        remaining = delay
        resume()
        callback()
      , remaining)

    isPaused = ->
      !!paused

    @isPaused = isPaused
    @resume = resume

    @

  $.fn.circular = (method) ->
    unless $.fn.circular.test
      $.fn.circular.private = undefined

    if method == 'api'
      Object.keys(methods)
    else if methods[method]
      methods[method].apply @, Array::slice.call(arguments, 1)
    else if typeof method is 'object' or not method
      methods.init.apply @, arguments
    else
      $.error 'Method ' + method + ' does not exist on jquery.circular'

  $.fn.circular.public = methods
  $.fn.circular.private = _internals
