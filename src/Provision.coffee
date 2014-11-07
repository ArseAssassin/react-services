module.exports =
  create: (dependencies, result) ->
    -> 
      args = Array.prototype.slice.call(arguments)
      dependencies: (services) -> 
        if dependencies
          dependencies.apply null, [services].concat(args)
        else
          {}
      resolve: (deps) ->
        result.apply(null, [deps].concat args)

  createSignal: (name) ->
    ->
      dependencies: (services) -> 
        message: services.Core.getMessage(name)
      resolve: (deps) ->
        deps.message
