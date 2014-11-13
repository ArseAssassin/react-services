helpers = require "./helpers"

lastId = 0

module.exports =
  create: (definition) -> 
    id = (lastId++).toString()

    value = null

    values = {}

    setValue = (key, value, setDirty) ->
      signalInstanceId = id + key

      setDirty ||= ->

      if value.promise
        if value.now
          values[key] = value.now
          setDirty(signalInstanceId)

        value.promise.then (x) ->
          values[key] = x
          setDirty(signalInstanceId)

      else
        values[key] = value
        setDirty(signalInstanceId)

    bind: (context) ->
      -> 
        args = Array.prototype.slice.call(arguments)
        hash = JSON.stringify args

        if values[hash] == undefined
          setValue hash, definition.initialValue.apply(deps: context.deps, args), context.setDirty

        context.markAsInteresting(id + hash)

        values[hash]

    handle: (event, activeSignals) ->
      handler = definition.handlers[event.type]
      if handler
        for k, v of values
          signalInstanceId = id + k

          if !activeSignals || activeSignals.indexOf(signalInstanceId) > -1
            setValue k, handler.call({deps: @deps, value: v}, event), @setDirty

    
