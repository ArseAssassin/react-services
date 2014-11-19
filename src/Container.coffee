DependencyManager = require "./DependencyManager"
helpers = require "./helpers"
_ = require "underscore-contrib"

module.exports =
  create: ->
    subscribers = []

    dependencyManager = DependencyManager.create()

    dirty = []
    activeSignals = []

    @setDirty = (signals) -> 
      dirty = dirty.concat signals

    @defineService = (name, service) ->
      dependencyManager.defineService name, service

    @addSubscriber = (subscriber) ->
      subscribers.push(subscriber)
      @_update(subscriber)

    @removeSubscriber = (subscriber) ->
      resetSignals(subscriber)
      subscribers.splice(subscribers.indexOf(subscriber), 1)

    resetSignals = (subscriber) ->
      signals = subscriber.interestingSignals || []
      while signals.length > 0
        signal = signals.pop()
        activeSignals.splice(activeSignals.indexOf(signal), 1)

      subscriber.interestingSignals = signals

    @_update = (subscriber) ->
      resetSignals(subscriber)
      subscriber.setDependencies subscriber.getDependencies(
        dependencyManager.services @setDirty, (x) ->
          subscriber.interestingSignals.push x
          activeSignals.push x
      )

    @update = ->
      dependencyManager.update @setDirty, ((x) -> activeSignals.indexOf(x) > -1)

      for subscriber in subscribers
        if _.some(subscriber.interestingSignals, (x) -> subscriber.dirty || dirty.indexOf(x) > -1)
          @_update(subscriber)

      dirty = []


    @
