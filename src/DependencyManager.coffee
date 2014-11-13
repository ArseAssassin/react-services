Core = require "./Core"
Signal = require "./Signal"
Provision = require "./Provision"
q = require "q"

_ = require "underscore-contrib"

module.exports = 
  create: ->
    services = {}
    core = Core.create()

    contexts = {}
    cache = {}

    dirty = true

    new ->
      setDirty = (id) ->
        dirty = true
        cache = {}


      @resolve = (dependencies) ->
        memoize = (id, value) ->
          cache[id] = value

        lookup = (id) ->
          cache[id]

        iter = ((dependencies, callStack) ->
          result = {}
          for name, context of dependencies
            id = context.id("")
            deps = context.dependencies(@services(id))
            result[name] = context.resolve(iter(deps, callStack.concat(id)))
          result
        ).bind @

        iter(dependencies, [])

      # @resolve = (dependencies) ->
      #   solveDependencyGraph = ((dependencies, callStack=[]) ->
      #     result = {}

      #     for name, context of dependencies
      #       id = context.id(callStack.join("."))
      #       deps = context.dependencies(@services(id), (context.args || []))
      #       result[name] = [context, solveDependencyGraph(deps, callStack.concat(id))]

      #     result
      #   ).bind @

      #   graph = solveDependencyGraph dependencies

      #   solveResults = (graph) ->
      #     result = {}

      #     promises = []

      #     for name, [context, dependencies] of graph
      #       value = solveResults(dependencies)
      #       if value.then
      #         promises.push value
      #       else
      #         value = context.resolve(value)

      #       result[name] = value

      #     if promises.length > 0
      #       q.allSettled(promises).then ->
      #         for name, value of result
      #           if value.then
      #             result[name] = context.resolve(value.inspect().value)

      #         result
      #     else
      #       result

      #   resolution = solveResults graph

      #   makePromise = (value) ->
      #     then: (f) ->
      #       f(value)

      #   if !resolution.then
      #     makePromise resolution
      #   else
      #     resolution

      @defineService = (name, provisions) ->
        results = {}

        for k, v of provisions
          results[k] = Provision.create v

        services[name] = results

      @services = (contextId) -> 
        _.merge services,
          createSignal: (definition) ->
            contexts[contextId] ||= Signal.create(definition, contextId, setDirty.bind(null, contextId))
            contexts[contextId]

      @flushEvents = -> core.flushEvents()

      @dirty = -> dirty
      @setClean = -> dirty = false

      @update = (events) ->
        # handleEvent = ((signal, handler, event) ->
        #   promises.push @resolve(handler.dependencies(@services(signal.contextId), event)).then (deps) ->
        #     handler.update(deps, event)
        # ).bind @

        for k, signal of contexts
          for event in events
            handler = signal.getHandler(event)

            if handler
              handler.update(@resolve(handler.dependencies(@services(signal.contextId), event)))

        # q.allSettled(promises).then (x) ->
        #   events.length > 0 || dirty == true


      @defineService "Core", core.getService()

      @



