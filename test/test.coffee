chai = require('chai')
sinon = require('sinon')
jQuery = $ = require('jquery')

require ('../jquery.circular')

assert = chai.assert
expect = chai.expect

emptyBody = '<html><body></body></html>'
emptyCarousel = '<html><body><div class="carousel"></div></body></html>'
fullCarousel = '<html><body><div class="carousel"><ul class="slides"><li class="slide" data-id=0>slide 1</li><li class="slide" data-id=1>slide 2</li></ul><ul class="controls"><li class="control" data-id=0>control 1</li><li class="control" data-id=1>control 1</li></ul></div></body></html>'

factory = (dom) ->
  $(dom)

describe '$.fn.circular', ->
  describe 'ok, it…', ->
    it 'exists', ->
      expect($.fn.circular).to.exist

    it 'is available on jQuery selectors (ie. jQuery runs fine lolz)', ->
      expect($()).to.have.property('circular')

  describe 'its API…', ->
    beforeEach ->
      @$fake = $()
      @$fake.circular()
      # FIXME: Maybe it would be better to extract the factory
      # to a named function, so that it can be tested against
      # (internals…)
      @api = @$fake.circular('api')

    it 'exposes init()', ->
      expect(@api).to.include('init')

    it 'exposes currentSlide()', ->
      expect(@api).to.include('currentSlide')

    it 'exposes currentControl()', ->
      expect(@api).to.include('currentControl')

    it 'exposes current()', ->
      expect(@api).to.include('current')

    it 'exposes pause()', ->
      expect(@api).to.include('pause')

    it 'exposes resume()', ->
      expect(@api).to.include('resume')

    it 'exposes jumpTo()', ->
      expect(@api).to.include('jumpTo')

    it 'exposes isRunning()', ->
      expect(@api).to.include('isRunning')

  # Called without inner DOM

  describe 'when called on an empty element, it…', ->
    beforeEach ->
      @$body = factory(emptyCarousel)
      @$carousel = @$body.find('.carousel')
      @$carousel.circular()

    it 'runs fine', ->
      # No slide atm, so it won't run, but it's up at least
      expect(@$carousel.circular('isRunning')).not.to.be.true

  ## Called with expected DOM

  describe 'when called on some compliant element, it…', ->
    beforeEach ->
      @$body = factory(fullCarousel)
      @$carousel = @$body.find('.carousel')
      @$carousel.circular()

    it 'runs fine', ->
      expect(@$carousel.circular('isRunning')).to.be.true

  ## TODO: Called with custom DOM
