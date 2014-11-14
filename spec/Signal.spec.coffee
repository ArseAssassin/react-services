Signal = require "../src/Signal"
q = require "q"

defaultContext = 
  markAsInteresting: ->
  setDirty: ->
  deps: {}

describe "Signal", ->
  it "should consume events when handler for type is defined", ->
    s = Signal.create
      initialValue: -> 0
      handlers:
        test: -> @value + 1

    s.bind(defaultContext)().must.eql 0

    s.handle.call(defaultContext, {type: "test"})
    s.getSignals().map (x) -> x.consumeEvents.call(defaultContext)

    s.bind(defaultContext)().must.eql 1

  it "should consume promises", ->
    deferred = null

    s = Signal.create
      initialValue: -> 0
      handlers:
        test: -> 
          deferred = q.defer()

          later: deferred.promise.then (x) ->
            x + 1


    s.bind(defaultContext)().must.eql 0

    s.handle.call(defaultContext, type: "test")
    s.getSignals().map (x) -> x.consumeEvents.call(defaultContext)

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
          now: @value + 1
          later: d.promise
            

    s.bind(defaultContext)().must.eql 0

    s.handle.call(defaultContext, type: "test")
    s.getSignals().map (x) -> x.consumeEvents.call(defaultContext)

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
          now: @value + 1
          later: d.promise
            
    i = 0

    context = {deps: {}, setDirty: (-> i = 1)}

    s.bind(defaultContext)()

    s.handle.call(context, {type: "test"})
    s.getSignals().map (x) -> x.consumeEvents.call(context)

    d.promise.then (x) ->
      i.must.eql 1

