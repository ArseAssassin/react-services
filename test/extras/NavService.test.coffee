index = require "../../src/index"

assert = require "assert"

describe "NavService", ->
  beforeEach ->
    location = 
      href: "/"
      pathname: "/"

    index.defineService "DOMService", ->
      window: -> {}
      document: -> location: location
      history: -> {}

    index.defineService "JQueryService", ->
      $: -> 
        JQuery = ->
          bind: ->
        JQuery.fn  = JQuery.prototype;
        JQuery

    require "../../src/extras/NavService"

  describe "#path", ->
    it "should propagate DOMService#document.location.href", ->
      assert.equal index.getValue("NavService#path"), "/"

  describe "#navigate", ->
    it "should set document href when pushState is not available", ->
      navigate = index.getValue("NavService#navigate")
      navigate("/hello")
      assert.equal index.getValue("DOMService#document").location.href, "/hello"

    it "should navigate to a relational path when path doesn't start with slash", ->
      navigate = index.getValue("NavService#navigate")
      navigate("relative/path")
      assert.equal index.getValue("DOMService#document").location.href, "/relative/path"

    it "should navigate to from root when path starts with a slash", ->
      navigate = index.getValue("NavService#navigate")
      navigate("relative/path")
      navigate("/root")
      assert.equal index.getValue("DOMService#document").location.href, "/root"

    it "should use pushState when available", ->
      path = ""
      index.defineService "DOMService", ->
        history: ->
          pushState: (state, title, url) ->
            path = url 
      
      navigate = index.getValue("NavService#navigate")
      navigate("/hello")

      assert.equal path, "/hello" 



