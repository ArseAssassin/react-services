q = require "q"

lastProvisionId = 0
createId = ->
  lastProvisionId++

module.exports =
  create: (callback) ->
    callback
