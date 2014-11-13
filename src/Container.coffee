DependencyManager = require "./DependencyManager"
helpers = require "./helpers"

module.exports =
  create: ->
    subscribers = []

    dirty = true

    dependencyManager = DependencyManager.create()

    @defineService = (name, service) ->
      dependencyManager.defineService name, service

    @addSubscriber = (subscriber) ->
      subscribers.push(subscriber)
      @_update(subscriber)

    @removeSubscriber = (subscriber) ->
      subscribers.splice(subscribers.indexOf(subscriber), 1)

    @_update = (subscriber) ->
      subscriber.setDependencies dependencyManager.resolve(subscriber.getDependencies(dependencyManager.services(subscriber, subscriber.id())))

    @forceUpdate = -> dirty = true

    @update = ->
      events = dependencyManager.flushEvents()
      if events.length > 0 
        dependencyManager.update(events)

      if dirty || dependencyManager.dirty()
        for subscriber in subscribers
          @_update(subscriber)

        dependencyManager.setClean()

      dirty = false


    @
