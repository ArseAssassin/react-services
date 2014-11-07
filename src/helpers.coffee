module.exports.merge = (a, b) ->
  x = {}
  for key, value of a
    x[key] = value
  for key, value of b
    x[key] = value

  x
