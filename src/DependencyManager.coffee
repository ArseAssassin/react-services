Core = require "./Core"
Signal = require "./Signal"
Provision = require "./Provision"
Service = require "./Service"
q = require "q"

_ = require "underscore-contrib"

module.exports = 
  create: ->
    services = {}

    core = Core.create()

    new ->
      @defineService = (name, provisions) ->
        services[name] = Service.create(provisions)

      @services = (setDirty, markAsInteresting=->) -> 
        s = {}
        for k, v of services
          s[k] = v.bind(s, setDirty, markAsInteresting)
        s

      @update = (setDirty, isActive) ->
        events = core.flushEvents()

        s = @services(setDirty)

        for name, service of services
          service.update(s, events, setDirty)

        @getSignals()
          .filter (x) -> isActive(x.id)
          .map (x) -> x.consumeEvents.call(deps: s, setDirty: setDirty)

      @getSignals = ->
        _.chain(services)
          .map (x) -> x.getSignals()
          .flatten()
          .value()


      @defineService "Core", core.getService()

      @



