merge = require("./helpers").merge

class DependencyManager
  constructor: () ->
    @subscribers = {}
    @data = {}

  updateField: (fieldName, value) ->
    @data[fieldName] = value

    for subscriberData in @getSubscribersForField(fieldName)
      newData = {}
      newData[subscriberData.targetField] = value(subscriberData.subscriber)

      subscriberData.subscriber.setServices newData
      subscriberData.subscriber.update()

  getSubscribersForField: (fieldName) ->
    @subscribers[fieldName] || []

  removeSubscriber: (subscriber) ->
    for own key, list of @subscribers
      @subscribers[key] = list.filter (subscriberData) -> subscriberData.subscriber != subscriber

  addSubscriber: (subscriber) ->
    if subscriber.subscribe
      subscribedFields = subscriber.subscribe

      existingData = {}

      for own targetField, field of subscribedFields
        currentSubscribers = @getSubscribersForField(field)

        if @data[field]
          existingData[targetField] = @data[field](subscriber)

        currentSubscribers.push(
          subscriber: subscriber,
          targetField: targetField
        )

        @subscribers[field] = currentSubscribers

      subscriber.setServices existingData

  updateProvider: (name, provider) ->
    for key, value of provider
      if key != "services"
        @updateField name + "#" + key, value

  clear: ->
    @subscribers = {}
    @data = {}

  getValue: (name) ->
    @data[name]()

module.exports = DependencyManager
