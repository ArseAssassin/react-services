helpers = require "./helpers"

module.exports =
  create: (definition, contextId, setDirty) -> 
    setDirty ||= ->
    definition.handlers ||= {}

    value = undefined

    setValue = (x) ->
      if x == value
        return

      if x.promise
        x.promise.then (x) ->
          setValue x

        if x.now != undefined
          setValue x.now
      else
        value = x
        setDirty()

      x

    setValue definition.initialValue()

    id: (name) -> name
    contextId: contextId
    dependencies: -> {}
    resolve: -> 
      value
    getHandler: (event) ->
      handler = definition.handlers[event.type]

      context = {value: value}

      if handler
        dependencies: (handler.getDependencies || -> {}).bind context
        update: (deps) ->
          setValue handler.getValue.call context, deps, event
          
