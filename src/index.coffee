DependencyManager = require "./DependencyManager"
merge = require("./helpers").merge

module.exports = ->
  dependencyManager = new DependencyManager

  defineService: (serviceName, constructor) ->
    currentState = {}
    newService = new constructor(currentState)

    updateService = (name) ->
      if !name
        dependencyManager.updateProvider serviceName, newService
      else
        dependencyManager.updateField "#{serviceName}##{name}", newService[name]

    dependencyManager.addSubscriber 
      setServices: (newState) ->
        currentState = merge currentState, newState
        newService = constructor(currentState)
        updateService()

      update: ->
        updateService()

      subscribe: newService.subscribe

    updateService()

    update: updateService


  useServices: ->
    setServices: (services) ->
      @services = merge this.services, services

    update: ->
      @setState
        services: @services

    componentWillMount: -> 
      dependencyManager.addSubscriber this

    componentWillUnmount: -> 
      dependencyManager.removeSubscriber this


  clear: ->
    dependencyManager.clear()


  getValue: (name) ->
    dependencyManager.getValue name
