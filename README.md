jquery.circular
===============

— *No! Not yet another fraking carousel library!*

— Here, grab that cookie.

— *Oh? All right then.*

Default settings
----------------

* 4s display per slide
* 1s transition between slides
* starts on first slide (id == 0)
* responsive-friendly DOM convention for slides and controls

Usage
-----

``` js
$('.wannabe-carousel').circular()
```

with `.wannabe-carousel` a container for slides and slide's controls. By
default, it would be of the following shape:

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

Triggerd by the default implementation of `jumpTo()` (see API below).


``` js
$('.wannabe-carousel').on('circular:jumped', function(event, newSlide, prevSlide) {
  // newSlide is the newly active slide
  // prevSlide is the former active slide
});
```

### circular:fading

Triggered when the active slide is about to become unactive and "fade" out.

``` js
$('.wannabe-carousel').on('circular:fading', function(event, prevSlide, nextSlide) {
  // prevSlide is the "fading" slide
  // nextSlide is the slide about to become the selected one
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

### circular:faded

Triggered when a slide has been selected and has been made visible, after the
transition's animation.

``` js
$('.wannabe-carousel').on('circular:faded', function(event, newSlide, prevSlide) {
  // newSlide is the new active, visible slide
  // prevSlide is the former active slide
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

Triggered when the carousel has been paused by calling `resume()`.

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
be overriden, although it will probably just work as is.

Bind events to the `jumpTo` handler to add custom interactions support. It
expects the DOM element you bind to to provide an `id` data-attribute matching
the slide's id you want to jump to, but in case this is not possible, an
explicit id can be passed as the second argument in the default implementation.

This callback will *not* resume the carousel if it has been paused.

``` js
// Why not enabling transitioning to the fourth slide by hovering its control?
$('.slide-control[data-id="3"]').on('hover', $('.wannabe-carousel').circular('jumpTo'))

// let's say we are able to pick a random number among the slides indexes, and
// are willing to crazy-jump to it each time a div is clicked:
id = randomSlideId()
$('body').on('click', 'div', $('.wannabe-carousel').circular('jumpTo', id))
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

"Trying" means those are my goals. For instance, it *does* (atm) make unfair
assumptions about your DOM tree. Oh my!

### What it is trying to do

* [KISS](http://en.wikipedia.org/wiki/KISS_principle)
* Simple code so that one can hack on
* Use a convention over configuration approach, but remain fully tweakable
* Modern patterns ([proper jQuery Plugin's API](http://kaibun.net/blog/2013/04/19/a-fully-fledged-coffeescript-boilerplate-for-jquery-plugins/),
  Deferred-based architecture, maybe generator-based at some point…)

### On the roadmap

* Overridable transition effect/logic
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
