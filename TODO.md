* fix version number in src/carousel.coffee
* create src/carousel.effects.coffee to store some custom effects; add examples in the README
* fix Travis build (ok in local)
* grunt-karma + karma-mocha + Istanbul for coverage
* jumpTo() should not be an event handler, but an API method to jump to a slide.
  The event handler should be named jumpedTo() and be a hook, called on
  'jumped' events.
* get rid of the assumption that controls are within slides' elements.
* allow to choose the data-attribute name.
* get rid of the unfair assumption that controls are in bijection with the slides: one may want to provide none to several controls for a specific slides.
* more useful hooks!
* use https://github.com/vojtajina/grunt-bump
