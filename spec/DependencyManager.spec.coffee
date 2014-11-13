DependencyManager = require "../src/DependencyManager"
Provision = require "../src/Provision"
Signal = require "../src/Signal"

q = require "q"

describe "DependencyManager", ->
  beforeEach ->
    @dm = DependencyManager.create()

  it "should add a service", ->
    @dm.defineService "TestService", {}

    @dm.services().TestService.must.eql({})


  it "should resolve a dependency", ->
    @dm.defineService "NameService",
      name: 
        getValue: -> "test"

    @dm.resolve(
      name: @dm.services().NameService.name()
    ).name.must.eql("test")


  it "should resolve a dependency with arguments", ->
    @dm.defineService "GreeterService",
      name: 
        getValue: (deps, name) -> "Hello #{name}!"

    @dm.resolve(
      name: @dm.services().GreeterService.name("tester")
    ).name.must.eql("Hello tester!")


  it "should resolve a dependency with dependencies", ->
    @dm.defineService "NameService",
      username: 
        getValue: -> "tester"

    @dm.defineService "GreeterService",
      greeting: 
        getDependencies: (services) ->
          username: services.NameService.username()
        getValue: (deps) -> "Hello #{deps.username}!"

    @dm.resolve(
      greeting: @dm.services().GreeterService.greeting()
    ).greeting.must.eql("Hello tester!")


  it "should resolve a dependency with parameters", ->
    @dm.defineService "GreeterService",
      greeting: 
        getDependencies: (services, name) ->
          name: services.YellerService.yell(name)
        getValue: (deps) -> "Hello #{deps.name}!"

    @dm.defineService "YellerService",
      yell: 
        getValue: (deps, name) -> name.toUpperCase()

    @dm.resolve(
      greeting: @dm.services().GreeterService.greeting("tester")
    ).greeting.must.eql("Hello TESTER!")


  describe "Signals", ->
    it "should return the default value of a signal if not initialized", ->
      @dm.defineService "Signal", 
        signal: 
          getDependencies: (services) ->
            signal: services.createSignal
              initialValue: -> "constant"
          getValue: (deps) -> deps.signal

      @dm.resolve(
        signal: @dm.services().Signal.signal()
      ).signal.must.eql("constant")


    it "should use events to fold signal value over time", ->
      @dm.defineService "Service",
        signal: 
          getDependencies: (services) ->
            signal: services.createSignal
              initialValue: -> 0
              handlers:
                test: 
                  getValue: -> @value + 1

          getValue: (deps) -> deps.signal

      @dm.resolve(
        signal: @dm.services().Service.signal()
      ).signal.must.eql(0)

      @dm.update([{type: "test"}])

      @dm.resolve(
        signal: @dm.services().Service.signal()
      ).signal.must.eql(1)


    it "should create new signal when getDependencies is called with different args", ->
      @dm.defineService "Service",
        signal:
          getDependencies: (services, value) ->
            signal: services.createSignal
              initialValue: -> value
          getValue: (deps) -> deps.signal

      @dm.resolve(
        signal: @dm.services().Service.signal(0)
      ).signal.must.eql(0)

      @dm.resolve(
        signal: @dm.services().Service.signal(1)
      ).signal.must.eql(1)

      
    it "should update a provision that depends on a service that depends on a signal", ->
      @dm.defineService "Service",
        signal:
          getDependencies: (services) ->
            signal: services.createSignal
              initialValue: -> 0
              handlers:
                test: 
                  getValue: -> @value + 1


          getValue: (deps) -> deps.signal

        double:
          getDependencies: (services) ->
            value: services.Service.signal()
          getValue: (deps) -> deps.value * 2

      dm = @dm

      @dm.resolve(
        signal: @dm.services().Service.double()
      ).signal.must.eql 0

      dm.update [
        type: "test"
      ]

      dm.resolve(
        signal: dm.services().Service.double()
      ).signal.must.eql 2
