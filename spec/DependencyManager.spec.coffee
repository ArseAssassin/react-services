DependencyManager = require "../src/DependencyManager"
Provision = require "../src/Provision"
Signal = require "../src/Signal"

demand = require "must"

describe "DependencyManager", ->
  beforeEach ->
    @dm = DependencyManager.create()

  it "should add a service", ->
    @dm.addService "TestService", {}

    @dm.services().TestService.must.eql({})


  it "should resolve a dependency", ->
    @dm.addService "NameService",
      name: Provision.create null, -> "test"

    resolution = @dm.resolve(
      name: @dm.services().NameService.name()
    )

    resolution.name.must.eql("test")


  it "should resolve a dependency with arguments", ->
    @dm.addService "GreeterService",
      name: Provision.create null, (deps, name) -> "Hello #{name}!"

    resolution = @dm.resolve(
      name: @dm.services().GreeterService.name("tester")
    )

    resolution.name.must.eql("Hello tester!")


  it "should resolve a dependency with dependencies", ->
    @dm.addService "NameService",
      username: Provision.create null, -> "tester"

    @dm.addService "GreeterService",
      greeting: Provision.create (
        (services) -> 
          username: services.NameService.username()
        ),
        (deps) -> "Hello #{deps.username}!"

    resolution = @dm.resolve(
      greeting: @dm.services().GreeterService.greeting()
    )

    resolution.greeting.must.eql("Hello tester!")


  it "should resolve a dependency with parameters", ->
    @dm.addService "GreeterService",
      greeting: Provision.create (
          (services, name) ->
            name: services.YellerService.yell(name)
        ),
        (deps) -> "Hello #{deps.name}!"

    @dm.addService "YellerService",
      yell: Provision.create null, (deps, name) -> name.toUpperCase()

    resolution = @dm.resolve(
      greeting: @dm.services().GreeterService.greeting("tester")
    )

    resolution.greeting.must.eql("Hello TESTER!")


  it "should cancel on unavailable dependencies", ->
    @dm.addService "Unavailable", 
      provision: Provision.create null, -> throw Signal.UNAVAILABLE

    @dm.resolve(
      provision: @dm.services().Unavailable.provision()
    ).must.eql(Signal.UNAVAILABLE)


  it "should cancel on waiting dependencies", ->
    @dm.addService "Unavailable", 
      provision: Provision.create null, -> throw Signal.WAITING

    @dm.resolve(
      provision: @dm.services().Unavailable.provision()
    ).must.eql(Signal.WAITING)


  describe "Signals", ->
    it "should return the default value of a signal if not initialized", ->
      @dm.addService "Signal", 
        signal: Signal.create "constant"

      @dm.resolve(
        signal: @dm.services().Signal.signal()
      ).signal.must.eql("constant")

    it "should use events to fold signal value over time", ->
      @dm.addService "Service",
        signal: Signal.create 0, ["test"], (x) -> x + 1

      results = @dm.resolve(
        signal: @dm.services().Service.signal()
        publish: @dm.services().Core.publish("test")
      )

      results.signal.must.eql(0)
      results.publish("something")

      @dm.update()

      @dm.resolve(
        signal: @dm.services().Service.signal()
      ).signal.must.eql(1)

    it "should call update for every matched events", ->
      @dm.addService "Service",
        signal: Signal.create 0, ["test"], (x) -> x + 1

      results = @dm.resolve(
        publish: @dm.services().Core.publish("test")
      )

      results.publish(1)
      results.publish(2)

      @dm.update()

      @dm.resolve(
        signal: @dm.services().Service.signal()
      ).signal.must.eql(2)

