jquery.circular
===============

— *No! Not yet another fraking carousel library!*

— But it's a dead-simple, modern one! It even has promises in it!

— *Oh? All right then.*

Default settings
----------------

* 4s display per slide
* 1s transition between slides
* starts on first slide
* responsive-friendly DOM convention for slides and controls

Usage
-----

``` jquery
$('.wannabe-carousel').circular()
```

with `.wannabe-carousel` a container for slides and slide's controls. By
default, it would be of the following shape:

``` haml
%div.wannabe-carousel
  %ul.slides
    %li.slide(data-id: 1)
      -# first slide's content
    %li.slide(data-id: 2)
      -# second slide's content
  %ul.controls
    %li.control(data-id: 1)
      -# first slide's control
    %li.control(data-id: 2)
      -# second slide's control
```

About this plugin
-----------------

### What it is trying *not* to do

* Fire a shitload of events and be overall complicated
* Make unfair assumptions about your DOM tree
* Be uncool

### What it is trying to do

* [KISS](http://en.wikipedia.org/wiki/KISS_principle)
* Simple code so that one can hack on
* Use a convention over configuration approach, but remain fully tweakable
* Modern patterns ([proper jQuery Plugin's API](http://kaibun.net/blog/2013/04/19/a-fully-fledged-coffeescript-boilerplate-for-jquery-plugins/),
  Deferred-based architecture…)

### Maybe one day?

* A *small* range of events (started, next, selected, stopped)
* Some hooks (beforeStart, beforeStop, things like that) because hooks are
  sweet
* A demo page with examples and a nice design

License
-------

MIT (see circular.coffee for details and credits/authorship).
