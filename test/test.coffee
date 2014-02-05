chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')
chai.use(sinonChai)
jQuery = $ = require('jquery')

require ('../build/circular')

assert = chai.assert
expect = chai.expect

emptyBody = '<body></body>'
emptyCarousel = '<body><div class="carousel"></div></body>'
fullCarousel = '<body><div class="carousel"><ul class="slides"><li class="slide" data-id=0>slide 1</li><li class="slide" data-id=1>slide 2</li></ul><ul class="controls"><li class="control" data-id=0>control 1</li><li class="control" data-id=1>control 1</li></ul></div></body>'

factory = (dom) ->
  $('<html>').html(dom)

$.fn.circular.test = true

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
      @api = @$fake.circular('api')

    # Not mandatory, but cleaning is always nice.
    afterEach ->
      @$fake = undefined
      @api = undefined

    it 'exposes init()', ->
      expect(@api).to.include('init')

    it 'exposes slides()', ->
      expect(@api).to.include('slides')

    it 'exposes controls()', ->
      expect(@api).to.include('controls')

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

    it 'exposes isAlive()', ->
      expect(@api).to.include('isAlive')

    it 'exposes isRunning()', ->
      expect(@api).to.include('isRunning')

  # Called without inner DOM

  describe 'when called on an empty element, it…', ->
    beforeEach ->
      @$body = factory(emptyCarousel)
      @$carousel = @$body.find('.carousel')
      @$carousel.circular()

    # Not mandatory, but cleaning is always nice.
    afterEach ->
      @$body = undefined
      @$carousel = undefined

    it 'runs fine', ->
      # No slides, so it won't "run", but it's "up" at least.
      expect(@$carousel.circular('isAlive')).to.be.true
      expect(@$carousel.circular('isRunning')).not.to.be.true

  ## Called with expected DOM

  describe 'when called on some compliant element, it…', ->
    beforeEach ->
      @$body = factory(fullCarousel)
      @$carousel = @$body.find('.carousel')

    # Not mandatory, but cleaning is always nice.
    afterEach ->
      @$body = undefined
      @$carousel = undefined

    it 'runs fine', ->
      @$carousel.circular()
      expect(@$carousel.circular('isAlive')).to.be.true
      expect(@$carousel.circular('isRunning')).to.be.true

    it 'fires circular:init', (done) ->
      @$carousel.on 'circular:init', (args...) =>
        expect(args.length).to.equal 2
        expect(args[0].type).to.equal 'circular:init'
        expect(args[1].length).to.equal 1
        expect(args[1].selector).to.equal @$carousel.selector
        done()
      @$carousel.circular()

    describe 'handles settings:', ->
      it 'autoStart is true by default', ->
        _resume = sinon.spy $.fn.circular.private, 'resume'
        @$carousel.circular()
        expect(_resume).to.have.been.calledOnce
        expect(@$carousel.circular('isRunning')).to.be.true
        $.fn.circular.private.resume.restore()

      it 'autoStart can be set to false', ->
        _resume = sinon.spy $.fn.circular.private, 'resume'
        @$carousel.circular({autoStart: false})
        expect(_resume).to.not.have.been.called
        expect(@$carousel.circular('isRunning')).to.be.false
        $.fn.circular.private.resume.restore()

    it 'can be paused', (done) ->
      @$carousel.circular()
      @$carousel.on 'circular:paused', (args...) =>
        expect(args.length).to.equal 3
        expect(args[0].type).to.equal 'circular:paused'
        expect(args[1]).to.have.keys 'id', 'slide', 'control'
        expect(args[2].length).to.equal 1
        expect(args[2].selector).to.equal @$carousel.selector
        expect(@$carousel.circular('isAlive')).to.be.true
        expect(@$carousel.circular('isRunning')).to.be.false
        done()
      @$carousel.circular('pause')

    # TODO: use sinon.spy to monitor $.fn.circular.private.* calls
    it 'can be resumed', (done) ->
      @$carousel.circular()
      @$carousel.on 'circular:resumed', (args...) =>
        expect(args.length).to.equal 3
        expect(args[0].type).to.equal 'circular:resumed'
        expect(args[1]).to.have.keys 'id', 'slide', 'control'
        expect(args[2].length).to.equal 1
        expect(args[2].selector).to.equal @$carousel.selector
        expect(@$carousel.circular('isAlive')).to.be.true
        expect(@$carousel.circular('isRunning')).to.be.true
        done()
      @$carousel.circular('resume')

  ## TODO: Called with custom DOM
  ## TODO: spec on events ordering / lifecycle
