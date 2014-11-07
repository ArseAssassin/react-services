Core = require "./Core"
Signals = require "./Signals"

module.exports = 
  create: ->
    services = 
      Core: Core.create()

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
            when Signals.UNAVAILABLE then e
            when Signals.WAITING then e
            else throw e

      @addService = (name, provisions) ->
        services[name] = provisions

      @services = -> services

      @



