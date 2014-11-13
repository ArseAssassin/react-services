q = require "q"

lastProvisionId = 0
createId = ->
  lastProvisionId++

module.exports =
  create: (data) ->
    data ||= {}
    
    -> 
      args = Array.prototype.slice.call(arguments)

      id: (callStack="") ->
        if data.provisionId == undefined
          data.provisionId = createId()
        callStack + data.provisionId + JSON.stringify(args)

      dependencies: (services) -> 
        result = if data.getDependencies
          data.getDependencies.apply null, [services].concat(args)
        else
          {}


      resolve: (deps) ->
        data.getValue.apply(null, [deps].concat args)

