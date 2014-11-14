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
      name: -> "test"

    @dm.services().NameService.name().must.eql "test"


  it "should resolve a dependency with arguments", ->
    @dm.defineService "GreeterService",
      name: (name) -> "Hello #{name}!"

    @dm.services().GreeterService.name("tester").must.eql("Hello tester!")


  it "should resolve a dependency with dependencies", ->
    @dm.defineService "NameService",
      username: -> "tester"

    @dm.defineService "GreeterService",
      greeting: -> 
        "Hello #{@deps.NameService.username()}!"

    @dm.services().GreeterService.greeting().must.eql("Hello tester!")


  it "should resolve a dependency with parameters", ->
    @dm.defineService "GreeterService",
      greeting: (name) -> "Hello #{@deps.YellerService.yell(name)}!"

    @dm.defineService "YellerService",
      yell: (name) -> name.toUpperCase()

    @dm.services().GreeterService.greeting("tester").must.eql("Hello TESTER!")


  describe "Signals", ->
    it "should return the default value of a signal if not initialized", ->
      @dm.defineService "Signal", 
        signal: Signal.create
          initialValue: -> "constant"

      @dm.services(->).Signal.signal().must.eql("constant")


    it "should use events to fold signal value over time", ->
      @dm.defineService "Service",
        signal: Signal.create
          initialValue: -> 0
          handlers: 
            test: -> @value + 1

      @dm.services(->).Service.signal().must.eql(0)
      @dm.services().Core.publish("test")()

      @dm.update((->), -> true)

      @dm.services().Service.signal().must.eql(1)


    it "should create new signal when getDependencies is called with different args", ->
      @dm.defineService "Service",
        signal: Signal.create
          initialValue: (value) -> value

      @dm.services(->).Service.signal(0).must.eql(0)

      @dm.services(->).Service.signal(1).must.eql(1)

      
    it "should update a provision that depends on a service that depends on a signal", ->
      @dm.defineService "Service",
        signal: Signal.create
          initialValue: -> 0
          handlers:
            test: -> @value + 1

        double: ->
          @deps.Service.signal() * 2

      dm = @dm

      @dm.services(->).Service.double().must.eql 0
      @dm.services(->).Core.publish("test")()
      dm.update((->), -> true) 

      dm.services().Service.double().must.eql 2
