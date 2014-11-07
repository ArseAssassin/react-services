Provision = require "./Provision"
Signals = require "./Signals"

module.exports =
  create: ->
    messages = {}
    getMessage: Provision.create null, (deps, name, defaultValue) -> 
      messages[name] || defaultValue
    publish: Provision.create null, (deps, name) -> (value) -> 
      messages[name] = value
