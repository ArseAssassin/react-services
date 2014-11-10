module.exports =
  UNAVAILABLE: "REACT-SERVICES-PROVISION-UNAVAILABLE"
  WAITING: "REACT-SERVICES-PROVISION-WAITING"
  create: (initialValue, wantedEvents, foldFunction) -> 
    value = undefined
    currentValue = ->
      value != undefined && value || initialValue

    result = ->
      dependencies: ->
      resolve: -> currentValue()

    result.update = (events) ->
      if foldFunction
        for event in events
          if wantedEvents.indexOf(event.type) > -1
            value = foldFunction(currentValue(), event.payload)
            
    result
