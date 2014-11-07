DependencyManager = require "../src/DependencyManager"
Provision = require "../src/Provision"
Signals = require "../src/Signals"

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
      provision: Provision.create null, -> throw Signals.UNAVAILABLE

    @dm.resolve(
      provision: @dm.services().Unavailable.provision()
    ).must.eql(Signals.UNAVAILABLE)


  it "should cancel on waiting dependencies", ->
    @dm.addService "Unavailable", 
      provision: Provision.create null, -> throw Signals.WAITING

    @dm.resolve(
      provision: @dm.services().Unavailable.provision()
    ).must.eql(Signals.WAITING)


  it "should resolve signals", ->
    results = @dm.resolve(
      publish: @dm.services().Core.publish("test")
      message: @dm.services().Core.getMessage("test", "default")
    )

    results.message.must.eql("default")
    results.publish("testies")

    results = @dm.resolve(
      message: @dm.services().Core.getMessage("test")
    )
    results.message.must.eql("testies")

