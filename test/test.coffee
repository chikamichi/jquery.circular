chai = require('chai')
sinon = require('sinon')
spy = sinon.spy
mock = sinon.mock
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

    it 'exposes its settings', ->
      expect(@api).to.include('settings')

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
      @$carousel = undefined
      @$body = undefined

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
      it 'the slides selector defaults to ".slides .slide"', ->
        @$carousel.circular()
        expect(@$carousel.circular('settings').aSlide).to.equal '.slides .slide'
        expect(@$carousel.circular('slides').selector).to.equal '.carousel .slides .slide'

      it 'the controls selector defaults to ".controls .control"', ->
        @$carousel.circular()
        expect(@$carousel.circular('settings').aControl).to.equal '.controls .control'
        expect(@$carousel.circular('controls').selector).to.equal '.carousel .controls .control'

      it 'the slides selector can be overriden', ->
        @$carousel.circular({aSlide: '.foo'})
        expect(@$carousel.circular('settings').aSlide).to.equal '.foo'
        expect(@$carousel.circular('slides').selector).to.equal '.carousel .foo'

      it 'the controls selector can be overriden', ->
        @$carousel.circular({aControl: '.bar'})
        expect(@$carousel.circular('settings').aControl).to.equal '.bar'
        expect(@$carousel.circular('controls').selector).to.equal '.carousel .bar'

      it 'the transition delay defaults to 1000ms', ->
        @$carousel.circular()
        expect(@$carousel.circular('settings').transitionDelay).to.equal 1000

      it 'the transition delay can be overriden', ->
        @$carousel.circular({transitionDelay: 250})
        expect(@$carousel.circular('settings').transitionDelay).to.equal 250

      it 'the display duration defaults to 4000ms', ->
        @$carousel.circular()
        expect(@$carousel.circular('settings').displayDuration).to.equal 4000

      it 'pausing on hover is disabled by default', (done) ->
        _hover = spy $.fn, 'hover'
        @$carousel.mouseenter =>
          expect(@$carousel.circular('isRunning')).to.be.true
          done()
        @$carousel.on 'circular:init', =>
          expect(@$carousel.circular('settings').pauseOnHover).to.equal false
          expect(@$carousel.circular('isRunning')).to.be.true
          expect(_hover).to.not.have.been.called
          @$carousel.hover.restore()
          @$carousel.mouseenter()
        @$carousel.circular()

      it 'pausing on hover can be enabled', (done) ->
        _hover = spy $.fn, 'hover'
        @$carousel.on 'circular:init', =>
          @$carousel.on 'circular:paused', =>
            expect(@$carousel.circular('isRunning')).to.be.false
            done()
          # FIXME: use .withArgs?
          expect(_hover).to.have.been.calledOnce
          expect(_hover).to.have.been.calledWith(@$carousel.circular('methods').pause, @$carousel.circular('methods').resume)
          @$carousel.hover.restore()
          @$carousel.mouseenter()
        @$carousel.circular({pauseOnHover: true})

      it 'direct jump (transitionDelay enforced to 0) is disabled by default', (done) ->
        _internals = null
        @$carousel.on 'circular:jumped', ->
          _internals.verify()
          done()
        @$carousel.on 'circular:init', =>
          _internals = mock(@$carousel.circular('_internals'))
          _internals.expects('transitionTo').once().withArgs(1, null)
          $(@$carousel.circular('controls')[1]).click()
        @$carousel.circular()

      it 'direct jump can be enabled', (done) ->
        _internals = null
        @$carousel.on 'circular:jumped', ->
          _internals.verify()
          done()
        @$carousel.on 'circular:init', =>
          _internals = mock(@$carousel.circular('_internals'))
          _internals.expects('transitionTo').once().withArgs(1, 0)
          $(@$carousel.circular('controls')[1]).click()
        @$carousel.circular({directJump: true})

      it 'the starting point defaults to the slide of id "0"', (done) ->
        @$carousel.on 'circular:init', =>
          expect(@$carousel.circular('current').id).to.equal 0
          done()
        @$carousel.circular()

      it 'the starting point can be overriden', (done) ->
        @$carousel.on 'circular:init', =>
          expect(@$carousel.circular('current').id).to.equal 1
          done()
        @$carousel.circular({startingPoint: 1})

      it 'autoStart is true by default', ->
        _resume = spy @$carousel.circular('_internals'), 'resume'
        @$carousel.circular()
        expect(_resume).to.have.been.calledOnce
        expect(@$carousel.circular('isRunning')).to.be.true
        @$carousel.circular('_internals').resume.restore()

      it 'autoStart can be set to false', ->
        _resume = spy @$carousel.circular('_internals'), 'resume'
        @$carousel.circular({autoStart: false})
        expect(_resume).to.not.have.been.called
        expect(@$carousel.circular('isRunning')).to.be.false
        @$carousel.circular('_internals').resume.restore()

      it 'a beforeStart hook is available', (done) ->
        hook = (currentSlide, $slides) =>
          expect(currentSlide.id).to.equal(@$carousel.circular('current').id)
          expect($slides.length).to.equal(@$carousel.circular('slides').length)
          expect(@$carousel.circular('isRunning')).to.be.false
        bs = spy(hook)
        @$carousel.on 'circular:init', =>
          expect(bs).to.have.been.calledOnce
          done()
        @$carousel.circular({beforeStart: bs})

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
