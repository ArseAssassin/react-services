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
        container.forceUpdate()

      componentWillMount: ->
        container.addSubscriber @

      componentWillUnmount: ->
        container.removeSubscriber @

      setDependencies: (deps) ->
        @dependencies = deps
        @setState
          dependencies: deps


    defineService: (name, service) ->
      container.defineService name, service

