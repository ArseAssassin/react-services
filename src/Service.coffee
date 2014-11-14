_ = require "underscore-contrib"

module.exports =
  create: (provisions) ->
    bind: (services, setDirty, markAsInteresting) ->
      results = {}

      for k, v of provisions
        results[k] = v.bind({deps: services, setDirty: setDirty, markAsInteresting: markAsInteresting})
      results

    update: (services, events) ->
      for event in events
        for k, v of provisions
          if v.handle
            v.handle.call({deps: services}, event)

    getSignals: ->
      _.chain(provisions)
        .map (x) -> x.getSignals && x.getSignals() || []
        .flatten()
        .value()

