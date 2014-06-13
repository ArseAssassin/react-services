React = require "React"

dependencyManager = new (require "./DependencyManager")

merge = (a, b) ->
  x = {}
  for key, value of a
    x[key] = value
  for key, value of b
    x[key] = value

  x

module.exports.defineService = (serviceName, constructor) ->
  currentState = {}
  newService = new constructor(currentState)

  updateService = (name) ->
    if !name
      dependencyManager.updateProvider serviceName, newService
    else
      dependencyManager.updateField "#{serviceName}##{name}", newService[name]

  dependencyManager.addSubscriber 
    setState: (newState) ->
      currentState = merge currentState, newState
      newService = constructor(currentState)
      updateService()

    subscribe: newService.subscribe

  updateService()

  update: updateService

module.exports.defineComponent = (component) ->
  oldMount    = component.componentWillMount    || (->)
  oldUnmount  = component.componentWillUnmount  || (->)

  component.componentWillMount = -> 
    dependencyManager.addSubscriber this
    oldMount.call(this)
  component.componentWillUnmount = -> 
    dependencyManager.removeSubscriber this
    oldUnmount.call(this)

  React.createClass component


module.exports.clear = ->
  dependencyManager.clear()