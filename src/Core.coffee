Provision = require "./Provision"
Signal = require "./Signal"
Queue = require "./Queue"

module.exports =
  create: ->
    queue = Queue.create()

    flushEvents: ->
      queue.flush()

    getService: ->
      publish: 
        getValue: (services, name) -> (payload) -> 
          queue.publish({type: name, payload: payload})

