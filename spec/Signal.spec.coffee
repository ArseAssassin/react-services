Signal = require "../src/Signal"
q = require "q"

defaultContext = 
  markAsInteresting: ->
  deps: {}

describe "Signal", ->
  it "should consume events when handler for type is defined", ->
    s = Signal.create
      initialValue: -> 0
      handlers:
        test: -> @value + 1

    s.bind(defaultContext)().must.eql 0

    s.handle.call(defaultContext, {type: "test"})

    s.bind(defaultContext)().must.eql 1

  it "should consume promises", ->
    deferred = null

    s = Signal.create
      initialValue: -> 0
      handlers:
        test: -> 
          deferred = q.defer()

          promise: deferred.promise.then (x) ->
            x + 1


    s.bind(defaultContext)().must.eql 0

    s.handle.call(defaultContext, type: "test")

    s.bind(defaultContext)().must.eql 0

    deferred.resolve(0)

    deferred.promise.then ->
      s.bind(defaultContext)().must.eql 1

    deferred.promise

  it "should update now and later with a promise", ->
    d = q.defer()
    s = Signal.create
      initialValue: -> 0
      handlers:
        test: (x) -> 
          d.resolve(5)
          promise: d.promise
          now: @value + 1
            

    s.bind(defaultContext)().must.eql 0

    s.handle.call(defaultContext, type: "test")

    s.bind(defaultContext)().must.eql 1

    d.promise.then (x) ->
      s.bind(defaultContext)().must.eql 5


  it "should call setDirty when mutated value", ->
    d = q.defer()
    s = Signal.create
      initialValue: -> 0
      handlers:
        test: (x) -> 
          d.resolve(5)
          promise: d.promise
          now: @value + 1
            
    i = 0

    s.bind(defaultContext)()

    s.handle.call({deps: {}, setDirty: (-> i = 1)}, {type: "test"})

    d.promise.then (x) ->
      i.must.eql 1

