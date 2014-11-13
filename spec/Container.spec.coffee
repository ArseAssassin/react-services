Signal = require "../src/Signal"
Container = require "../src/Container"

describe "Container", ->
  beforeEach ->
    @container = Container.create()

  it "should update a newly added subscriber", ->
    foo = "foo"

    @container.defineService "Service",
      foo: -> "bar"

    @container.addSubscriber 
      getDependencies: (services) ->
        foo: services.Service.foo()
      setDependencies: (deps) ->
        foo = deps.foo

    foo.must.eql("bar")

  it "should apply queued events to signals when update is called", ->
    foo = "foo"

    @container.defineService "Service",
      signal: Signal.create
        initialValue: -> 0
        handlers:
          test: -> @value + 1

    subscriber = 
      getDependencies: (services) ->
        signal: services.Service.signal()
        publish: services.Core.publish("test")

      setDependencies: (deps) ->
        subscriber.deps = deps

    @container.addSubscriber(subscriber)

    subscriber.deps.signal.must.eql(0)

    subscriber.deps.publish("something")
    
    @container.update()

    subscriber.deps.signal.must.eql(1)

  it "should mark interesting signals in the call stack", ->
    @container.defineService "Service",
      signal: Signal.create
        initialValue: -> 0

    subscriber =
      getDependencies: (deps) ->
        signal: deps.Service.signal()
      setDependencies: (deps) ->
        subscriber.deps = deps

    @container.addSubscriber(subscriber)

  it "should invalidate two signal dependencies separately", ->
    @container.defineService "Service",
      signal: Signal.create
        initialValue: -> 0
        handlers:
          test: -> 1

      signal2: Signal.create
        initialValue: -> 0
        handlers:
          test2: -> 1

    subscriber1 =
      getDependencies: (deps) ->
        signal: deps.Service.signal()
        update: deps.Core.publish("test")
      setDependencies: (deps) ->
        subscriber1.deps = deps

    @container.addSubscriber(subscriber1)

    i = 0
    subscriber2 =
      getDependencies: (deps) ->
        i++
        signal: deps.Service.signal2()
      setDependencies: (deps) ->
        subscriber2.deps = deps

    @container.addSubscriber(subscriber2)

    i.must.eql 1

    subscriber1.deps.update()
    @container.update()
    subscriber1.deps.update()

  #   i.must.eql 2

  it "should ignore events to suspended signals", ->
    @container.defineService "Service",
      signal: Signal.create
        initialValue: -> 0
        handlers:
          test: -> @value + 1

    subscriber =
      getDependencies: (deps) ->
        signal: deps.Service.signal()
        publish: deps.Core.publish("test")
      setDependencies: (deps) ->
        subscriber.deps = deps

    @container.addSubscriber subscriber

    subscriber.deps.signal.must.eql 0
    subscriber.deps.publish()
    @container.update()
    subscriber.deps.signal.must.eql 1

    @container.removeSubscriber subscriber

    subscriber.deps.publish()
    @container.update()

    @container.addSubscriber subscriber

    subscriber.deps.signal.must.eql 1





