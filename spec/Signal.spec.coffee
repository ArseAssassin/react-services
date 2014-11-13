Signal = require "../src/Signal"
q = require "q"

describe "Signal", ->
  it "should consume events when handler for type is defined", ->
    s = Signal.create
      initialValue: -> 0
      handlers:
        test:
          getValue: -> @value + 1

    s.resolve().must.eql 0

    s.getHandler({type: "test"}).update(null)

    s.resolve().must.eql 1

  it "should consume promises", ->
    deferred = null

    s = Signal.create
      initialValue: -> 0
      handlers:
        test: 
          getValue: (x) -> 
            deferred = q.defer()

            promise: deferred.promise.then (x) ->
              x + 1


    s.resolve().must.eql 0

    s.getHandler({type: "test"}).update(null)

    s.resolve().must.eql 0
    deferred.resolve(0)
    deferred.promise.then ->
      s.resolve().must.eql 1

    deferred.promise

  it "should update now and later with a promise", ->
    s = Signal.create
      initialValue: -> 0
      handlers:
        test:
          getValue: (x) -> 
            d = q.defer()
            d.resolve(5)
            promise: d.promise
            now: @value + 1
            

    s.resolve().must.eql 0

    promise = s.getHandler({type: "test"}).update(null)

    s.resolve().must.eql 1

    promise.promise.then (x) ->
      s.resolve().must.eql 5
