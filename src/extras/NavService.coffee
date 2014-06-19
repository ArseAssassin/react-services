defineService = require("../index").defineService

currentPath = null

navigate = (path) ->
  currentPath = path
  Service.update()

Service = defineService "NavService", (services) ->
  if services.window && services.$
    services.$(services.window).bind "popstate", (e) ->
      navigate location.pathname
      e.preventDefault();

  if services.document != undefined && currentPath == null
    currentPath = services.document.location.href

  subscribe:
    document: "DOMService#document"
    window: "DOMService#window"
    history: "DOMService#history"
    $: "JQueryService#$"

  navigate: () -> (path) -> 
    if path.indexOf("/") != 0
      parts = currentPath.split("/")
      parts.pop()
      path = parts.join("/") + "/" + path

    if services.history.pushState
      services.history.pushState null, null, path
    else
      services.document.location.href = path

    navigate path

  path: () -> 
    services.document.location.pathname

  title: () -> "Somelia"
  setTitle: () -> (title) -> 
    completeTitle = "Somelia" + title
    services.$("title").html completeTitle
    updateField "NavService#title", () -> completeTitle

