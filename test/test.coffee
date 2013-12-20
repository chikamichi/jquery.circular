jsdom = require("jsdom")
chai = require('chai')
sinon = require('sinon')
jQuery = $ = require('jquery')

require ('../jquery.circular')

assert = chai.assert
expect = chai.expect

document = jsdom.jsdom("<html><head></head><body>hello world</body></html>")
window = document.parentWindow

describe "dummy test", ->
  it "should be true", ->
    expect(true).to.be.true

describe "$.fn.circular", ->
  it "exists", ->
    expect($.fn.circular).to.exist

  it "can run", ->
