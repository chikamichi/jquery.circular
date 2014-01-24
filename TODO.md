* grunt-karma + karma-mocha + Istanbul for coverage
* jumpTo() should not be an event handler, but an API method to jump to a slide.
  The event handler should be named jumpedTo() and be a hook, called on
  'jumped' events.
* get rid of the assumption that controls are within slides' elements. Use
  absolute references to the DOM?
* use https://github.com/vojtajina/grunt-bump
