module.exports = 
  create: ->
    messages = []

    flush: ->
      oldMessages = messages
      messages = []
      oldMessages

    publish: (message) ->
      messages.push message
