_ = require "underscore-contrib"

Queue = require "./Queue"
helpers = require "./helpers"

lastId = 0

module.exports =
  create: (definition) -> 
    id = (lastId++).toString()

    value = null

    values = {}

    events = []

    definition.handlers ||= {}

    bind: (context) ->
      -> 
        args = Array.prototype.slice.call(arguments)
        hash = id + JSON.stringify args

        if values[hash] == undefined
          sig = SignalInstance.create(hash, definition, args)
          values[hash] = sig
          sig.initialize.call({deps: context.deps, setDirty: context.setDirty})

        context.markAsInteresting(hash)

        values[hash].getValue()

    handle: (event) ->
      handler = definition.handlers[event.type]

      if handler
        events.push(event)
        for k, signalInstance of values
          signalInstance.handle(event)

    getSignals: ->
      _.values(values)
    

SignalInstance =
  create: (id, definition, args) ->
    currentValue = null
    events = Queue.create()

    setValue = (value) ->
      if value != undefined && value != null && value.later
        if value.now != undefined
          setValue.call(@, value.now)

        value.later.then ((x) ->
          currentValue = x
          @setDirty(id)
        ).bind @

      else
        if value != currentValue
          currentValue = value
          @setDirty(id)

    id: id

    initialize: ->
      setValue.call @, definition.initialValue.apply(@, args)

    handle: (event) ->
      events.publish event

    getValue: -> currentValue

    consumeEvents: ->
      for event in events.flush()
        setValue.call @, definition.handlers[event.type].apply({deps: @deps, value: currentValue}, [event].concat(args))
