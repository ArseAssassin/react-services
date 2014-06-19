defineService = require("../index").defineService

_$ = null

Service = defineService "JQueryService", (services) ->
  $: -> _$

poll = ->
  if typeof $ != "undefined"
    _$ = $
    Service.update()
  else
    setTimeout(poll, 1000)

