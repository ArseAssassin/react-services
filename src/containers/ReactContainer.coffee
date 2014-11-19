Container = require "../Container"

module.exports =
  create: ->
    container = Container.create()

    update = ->
      requestAnimationFrame(update)
      container.update()

    update()

    getMixin: ->
      updateDependencies: ->
        @dirty = true

      componentWillMount: ->
        @dirty = false
        container.addSubscriber @

      componentWillUnmount: ->
        container.removeSubscriber @

      setDependencies: (deps) ->
        @dirty = false
        @dependencies = deps
        @setState
          dependencies: deps


    defineService: (name, service) ->
      container.defineService name, service

