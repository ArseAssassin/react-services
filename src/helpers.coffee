module.exports =
  makePromise: (value) ->
    then: (f) ->
      f(value)
