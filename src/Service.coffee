module.exports =
  create: (provisions) ->
    bind: (services, setDirty, markAsInteresting) ->
      results = {}

      for k, v of provisions
        results[k] = v.bind({deps: services, setDirty: setDirty, markAsInteresting: markAsInteresting})
      results

    update: (services, events, setDirty, activeSignals) ->
      for event in events
        for k, v of provisions
          if v.handle
            v.handle.call({deps: services, setDirty: setDirty}, event, activeSignals)
