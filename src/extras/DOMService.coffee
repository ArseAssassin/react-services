defineService = require("../index").defineService

Service = defineService "DOMService", ->
  document: -> document
  window: -> window
  history: -> history
