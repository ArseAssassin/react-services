Core = require "./Core"
Signal = require "./Signal"

module.exports = 
  create: ->
    toUpdate = []
    core = Core.create()
    services = 
      Core: core.getService()

    new ->
      @resolve = (dependencies) ->
        @iter = (dependencies) ->
          result = {}
          for k, v of dependencies
            result[k] = v.resolve(@resolve(v.dependencies(@services())))
          result

        try
          @iter(dependencies)
        catch e
          switch e
            when Signal.UNAVAILABLE then e
            when Signal.WAITING then e
            else throw e

      @addService = (name, provisions) ->
        services[name] = provisions
        
        for k, v of provisions
          if v.update
            toUpdate.push(v.update)

      @services = -> services

      @update = ->
        events = core.flushEvents()
        for update in toUpdate
          update(events)

      @



