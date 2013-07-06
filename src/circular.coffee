###
jQuery Circular Plugin v0.1

Release: 06/07/2013
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
  _nbSlides = null
  _interval = null

  # Public API.
  methods =
    init: (options) ->
      $this = $(@)
      $.extend _settings, (options or {})
      _slides = $(_settings.a_slide, $this)
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

  # Private API.
  _internals =
    # Set proper CSS classes on unactive/active slides and controls.
    setActiveSlide: ->
      id = _current + 1
      $(_settings.a_ctl, $this).removeClass('active')
      $(_settings.a_ctl + "[data-id=#{id}]", $this).addClass('active')
      $(_settings.a_slide, $this).removeClass('active')
      $(_settings.a_slide + "[data-id=#{id}]", $this).addClass('active')

    next: ->
      if _current + 1 < _nbSlides
        _current + 1
      else
        0

    # Looping.
    #
    # Call this to reinit the carousel from the current starting point.
    start: ->
      setInterval(->
        faded = $(_slides[_current]).fadeOut(_settings.transitionDelay)
                                    .promise()
        _current = _internals.next()
        faded.done ->
          _internals.setActiveSlide()
          $(_slides[_current]).fadeIn(_settings.transitionDelay)
      , _settings.transitionDelay + _settings.displayDuration)

    # Listen for events such as clicking on a control.
    bindEvents: ->
      # React upon a control being clicked: switch to its matching slide, reset
      # the loop.
      $(_settings.a_ctl, $this).click (e) ->
        selected = $(@).data("id") - 1
        window.clearInterval(_interval)
        $(_slides[_current]).hide()
        _current = selected
        _internals.setActiveSlide()
        $(_slides[selected]).show()
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
