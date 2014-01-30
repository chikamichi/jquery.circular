jquery.circular
===============

— *No! Not yet another fraking carousel library!*

— Here, grab that circular cookie.

— *Oh? All right then.*

[![Build Status](https://travis-ci.org/chikamichi/jquery.circular.png)](https://travis-ci.org/chikamichi/jquery.circular)

jquery.circular is a carousel backend library, targeted at front-end **developers**.

If you are:

* looking for a fully customizable, KISS carousel library
* tired of tweaking (as in, re-writing) conceptually closed jQuery libraries
* unwilling to waste time implementing your own carousel backend, though

then, this may be of some interest to you.

Default settings
----------------

* 4s display per slide
* 1s fade-in/out transition between slides
* starts on first slide (id == 0)

All of this is overridable. It supports defining custom transitions,
provides hooks to interfer with the carousel during its lifecycle,
exposes clean public and internal APIs.

Don't fancying the default fade-in/out effect? Want something more
*edge-casy*? Like, say…

* sliding horizontally movie trailers' slides
* while altering opacity
* while allowing to fade to a video, fullscreen, upon clicking a slide
* not forgetting to pause the carousel until it's resumed (closed the video)
* while monitoring in real-time some trailer API so as to be able to feed the carousel in with the most recent additions

It's problem: just wire things up around circular's backbone of API, hooks and events!

Usage
-----

``` js
$('.wannabe-carousel').circular()
```

with `.wannabe-carousel`, a container for some slides and slide's controls.

It could be of the following shape:

``` haml
%div.wannabe-carousel
  %ul.slides
    %li.slide(data-id: 0)
      -# first slide's content
    %li.slide(data-id: 1)
      -# second slide's content
  %ul.controls
    %li.control(data-id: 0)
      -# first slide's control
    %li.control(data-id: 1)
      -# second slide's control
```

If the carousel's structure changes during its lifecycle (adding/removing
slides…), one must re-create the `circular` instance. This may change in
the future (adding/removing slides and controls).

Settings
--------

### aSlide

Defines what maps to a slide. It is a [jQuery selector][selector] resolved
within the container, so actually it could be anything within your 'body' if
you'd like to.

It is expected to be associated a [data-attribute][data-attribute], `data-id`,
with a *unique* slide id within the slides set.

*Default:* `'.slides .slide'`

### aControl

Defines what maps to a slide's control. Same as for `aSlide`.

It is expected to be associated a data-attribute `data-id` matching one of the
id provided by a slide from the matching slides set.

*Default:* `'.controls .control'`

### transitionDelay

In milliseconds, the duration of the transition.

It will be passed as `delay` to any custom animation function.

*Default:* `1000`

### displayDuration

In milliseconds, the duration of display.

*Default:* `4000`

### directJump

Whether to skip animations when jumping to a slide using a control.

Actually, this sets the `delay` parameter available to animations callbacks to
the value `0`. Callbacks are free to implement any custom logic in this case.

*Default:* `false`

### pauseOnHover

Whether to pause the carousel when hovered.

It binds to the container. To implement custom behavior, bind to whatever you'd
like using the `pause()` and `resume()` functions from the API.

*Default:* `false`

### startingPoint

Defines which `data-id` to begin with.

*Default:* `0`

### autoStart

Whether to start running the carousel when initialized.

*Default:* `true`

### beforeStart

A hook for you to interfer with the carousel before it gets started.

Called at initialization time, just before `start()` (that is, will be called
even if `autoStart` is `false`).

*Arguments*:

* currentSlide: the current slide's descriptor (see below)
* $slides: jQuery selector for the slides set

*Default:* empty hook

### effects: in|out

Implement custom animations for the transitions.

A transition between two slides occurs in a fixed fashion (at least for the
time being): the current slide "moves away", then the next slide "comes in".
In the default implementation, those two events are schedulded so that the
slide that "comes in" waits for the slide that "moves away" to effectively
vanish, in a fade out/fade in animation. The scheduling is enforced by
promises.

One can override the effects for the "moves away" (`effects.out`) and "comes
in" (`effects.in`) animations, as long as the implementations are exposed
wrapped in deferrables exposing a `promise()` accessor (in the same way that
jQuery's Deferred API is designed).

Implementations must be functions returning functions. They receive
`delay`, the transition delay from the settings, as their sole argument,
and are to be executed in the context of the moving slide (that is, the
"current slide" while it's moving away, the "next slide" while it's coming
in).

Promises allow for custom scheduling. For instance, to provide horizontal
sliding animations, using a Backbone View and some CoffeeScript just
because we can (and for a greater expressiveness/length ratio):

``` coffee
class Carousel extends Backbone.View
  render: ->
    @$el.circular
      beforeStart: @prepare
      effects:
        out: @slideOut
        in: @slideIn
    @
    
  # Prepare the carousel for our custom transition effect, that is,
  # horizontal sliding where order does not matter.
  prepare: (currentSlide, $slides) =>
    w = currentSlide.slide.width()
    h = currentSlide.slide.height()
    # Set dimensions of the carousel's container, for slides will be
    # in absolute position.
    @$el.css
      height: "#{h}px"
      overflow: 'hidden'
    # Move all slides to the right, but the first one.
    $slides.css _({position: 'absolute'}).extend(@pos(w))
    currentSlide.slide.css @pos(0)
    $slides.show()
    
  # A slide must go away. It's currently visible, let's slide it horizontally
  # to the left, then reset its position to the right.
  #
  # Note: the surrounding deferred allows to decouple the sliding effect from
  # the transition lifecycle. In our custom transition effect, we want the
  # next slide to slide in *right away*, not until after the current slide has
  # slided out completely.
  slideOut: (delay) =>
    carousel = @
    processing = $.Deferred()
    ->
      w = $(@).width()
      cssStep1 = _(carousel.pos(w, true)).extend({opacity: 0.2})
      cssStep2 = _(carousel.pos(w)).extend({opacity: 1})
      $(@).animate(cssStep1, delay)
          .promise().done -> $(@).css(cssStep2)
      processing.resolve()
      processing

  # A slide must be displayed. It's currently hidden to the right, let's slide
  # it horizontally to the original position.
  slideIn: (delay) =>
    carousel = @
    ->
      $(@).animate(carousel.pos(0), delay)

  # Where to place a slide, using left/right offsets.
  # A "lefty" slide is to be positionned on the left side of the
  # carousel's container, a "righty" one (default case)… on
  # the right side.
  pos: (offset, lefty = false) ->
    if offset == 0
      left: 0
      right: 0
    else if lefty
      left: "-#{offset}px"
      right: "#{offset}px"
    else
      left: "#{offset}px"
      right: "-#{offset}px"
```

Hopefully this cumbersome example makes it more obvious how to use
circular's API to implement custom behavior, while relying on its
core loop implementation to orchestrate the carousel's lifecycle.

Events
------

jquery.circular provides a few events you can bind to. Most of them return
slide objects. Those "slides" are actually returned as slides *descriptors*
(not DOM nodes *per se*): those are objects of the following shape (also see
the `current()` method of the API described in the next section):

``` js
{
  id: Integer,                      // current slide's id
  slide: jQuery.fn.jQuery.init[1],  // a jQuery matcher for the current slide
  control: jQuery.fn.jQuery.init[1] // a jQuery matcher for the current slide's control
}
```

All callbacks take an optional last argument, which is the jQuery matcher you
are binding to (`$(this)`, that is). This may come in handy if you change the
callback's scope, for whatever reason. For the sake of simplicity, this last
argument is not shown in the code examples below.

### circular:init

Triggered when the carousel starts.

``` js
$('.wannabe-carousel').on('circular:init', function() {
  // sit and watch
})
```

### circular:jumped

Triggered by the default implementation of `jumpTo()` (see API below).


``` js
$('.wannabe-carousel').on('circular:jumped', function(event, newSlide, prevSlide) {
  // newSlide is the newly active slide
  // prevSlide is the former active slide
});
```

### circular:selected

Triggered when a slide has been selected, either when a automated transition
occurs or when a manual selection was performed/triggered.

This event fires in between the transition's animation (typically, before the
selected slide "fades" in, and after the previously active slide has "fade"
out).

``` js
$('.wannabe-carousel').on('circular:selected', function(event, slide) {
  // slide is the selected slide
});
```
### circular:fading

Triggered when the active slide is about to become inactive and replaced by
another slide.

``` js
$('.wannabe-carousel').on('circular:fading', function(event, prevSlide, nextSlide) {
  // prevSlide is the "fading" slide
  // nextSlide is the slide about to become the selected one
});
```

### circular:faded:out

Triggered when a slide has completed its animation of "fading" out.

``` js
$('.wannabe-carousel').on('circular:faded', function(event, newSlide, prevSlide) {
  // newSlide is the new active, visible slide
  // prevSlide is the former active slide
});
```

### circular:faded:in

Triggered when a slide has been selected and has been made visible, after the
transition's animation.

``` js
$('.wannabe-carousel').on('circular:faded', function(event, newSlide, prevSlide) {
  // newSlide is the new active, visible slide
  // prevSlide is the former active slide
});
```

### circular:toSelf

Triggered when an attempt to transitioning to the currently active slide has
been made.

The transition is invalid (nothing happpens), but this special event is fired
to notify about the attempt.

``` js
$('.wannabe-carousel').on('circular:toSelf', function(event, slide) {
  // slide is the selected slide
});
```

### circular:paused

Triggered when the carousel has been paused by calling `pause()`.

``` js
$('.wannabe-carousel').on('circular:paused', function(event, currentSlide) {
  // the carousel was paused on currentSlide
});
```

### circular:resumed

Triggered when the carousel has been resumed by calling `resume()`.

``` js
$('.wannabe-carousel').on('circular:resumed', function(event, currentSlide) {
  // the carousel was resumed, starting from currentSlide
});
```

Public API
----------

### init()

Inits the carousel. It should not be called more than once, and will actually
be ran automatically when calling `.circular()` on a jQuery matcher.

### slides()

Returns the slides set as a jQuery selector.

``` js
$('.wannabe-carousel').circular('slides')
```

### controls()

Returns the slides' controls set as a jQuery selector.

``` js
$('.wannabe-carousel').circular('controls')
```

### currentSlide()

Returns the current slide's DOM element.

``` js
$('.wannabe-carousel').circular('currentSlide')
```

### currentControl()

Returns the DOM element for the current slide's control.

``` js
$('.wannabe-carousel').circular('currentControl')
```

### current()

Returns both current slide and current slide's control DOM elements as an
object, under the `slide` and `control` properties respectively.

``` js
$('.wannabe-carousel').circular('current')
```

### pause()

Pauses the carousel, if currently running.

``` js
$('.wannabe-carousel').circular('pause')
```

### resume()

Resumes the carousel, if not currently running.

``` js
$('.wannabe-carousel').circular('resume')
```

### jumpTo

* arguments: `event[, id]`

This is an *event handler* implementing the business logic involved when jumping
to a specific slide. By default, it relies on a default implementation that can
be overriden, although it will probably just be fine in most cases.

Bind events to the `jumpTo` handler to add custom interactions support. It
expects the DOM element you bind to to provide an `id` data-attribute matching
the slide's id you want to jump to, but in case this is not possible, an
explicit id can be passed as the second argument.

This callback will *not* resume the carousel if it has been paused.

``` js
// Why not enabling transitioning to the fourth slide by hovering (default: clicking) its control?
$('.slide-control[data-id="3"]').on('hover', $('.wannabe-carousel').circular('jumpTo'))

// let's say we are able to pick a random number among the slides indexes, and
// are willing to crazy-jump to it each time a div is clicked:
$('body').on('click', 'div', function() {
  id = getRandomSlideId()
  $('.wannabe-carousel').circular('jumpTo', id);
})
```

### isRunning()

Checks whether the carousel's internal loop is running.

``` js
$('.wannabe-carousel').circular('isRunning')
```

About this plugin
-----------------

### What it is trying *not* to do

* Make unfair assumptions about your DOM tree
* Be overall complicated
* Provide styles, pictures…

### What it is trying to do

* [KISS](http://en.wikipedia.org/wiki/KISS_principle)
* Simple code so that one can hack on
* Use a convention over configuration approach, but remain fully tweakable
* Modern patterns ([proper jQuery Plugin's API](http://kaibun.net/blog/2013/04/19/a-fully-fledged-coffeescript-boilerplate-for-jquery-plugins/),
  Deferred-based architecture, maybe generator-based at some point…)

### On the roadmap

* Allow the slides and the controls to be anywhere in the DOM (fully
  data-\* based), removing any unfair assumption about your DOM tree
* Some more events (started, stopped, maybe paused/resumed)
* Some hooks (beforeStart, beforeStop, things like that)
* A demo page with examples and a nice design!

When this is implemented, release 0.1.0 and start using SemVer.

See TODO.md for other ideas.

License
-------

MIT (see circular.coffee for details and credits/authorship).

  [selector]: http://api.jquery.com/category/selectors/
  [data-attribute]: http://api.jquery.com/data/
