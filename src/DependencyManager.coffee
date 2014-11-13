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

      @update = (setDirty, activeSignals) ->
        events = core.flushEvents()

        s = @services()

        for name, service of services
          service.update(s, events, setDirty, activeSignals)

      @defineService "Core", core.getService()

      @



