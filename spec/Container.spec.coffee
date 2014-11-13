Container = require "../src/Container"

describe "Container", ->
  beforeEach ->
    @container = Container.create()

  it "should update a newly added subscriber", ->
    foo = "foo"

    @container.defineService "Service",
      foo:
        getValue: -> "bar"

    @container.addSubscriber 
      id: -> "id"
      getDependencies: (services) ->
        foo: services.Service.foo()
      setDependencies: (deps) ->
        foo = deps.foo

    foo.must.eql("bar")

  it "should apply queued events to signals when update is called", ->
    foo = "foo"

    @container.defineService "Service",
      signal: 
        getDependencies: (services) ->
          signal: services.createSignal
            initialValue: -> 0
            handlers:
              test: 
                getValue: (deps) -> @value + 1

        getValue: (deps) -> deps.signal


    subscriber = 
      id: -> "id"
      getDependencies: (services) ->
        signal: services.Service.signal()
        publish: services.Core.publish("test")

      setDependencies: (deps) ->
        subscriber.deps = deps

    @container.addSubscriber(subscriber)

    subscriber.deps.signal.must.eql(0)

    subscriber.deps.publish("something")
    @container.update({type: "test"})

    subscriber.deps.signal.must.eql(1)

