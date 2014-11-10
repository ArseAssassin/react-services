Provision = require "./Provision"
Signal = require "./Signal"
Queue = require "./Queue"

module.exports =
  create: ->
    queue = Queue.create()

    flushEvents: ->
      queue.flush()

    getService: ->
      publish: Provision.create null, 
        (deps, name) -> (payload) -> queue.publish({type: name, payload: payload})
