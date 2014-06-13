DependencyManager = require "../src/DependencyManager"

assert = require "assert"

describe "DependencyManager", ->
  dependencyManager = null

  TestSubscriber = (subscriptions=null) ->
    subscriptions ||= 
      testProvision: "TestService#testProvision"
    state = {}
    this.subscribe = subscriptions

    this.setState = (newState) ->
      state = newState
    this.getState = ->
      state

    dependencyManager.addSubscriber this

    this

  makeTestService = (value="testProvision") ->
    dependencyManager.updateProvider "TestService",
      testProvision: -> value

  beforeEach ->
    dependencyManager = new DependencyManager

  describe "adding subscribers", ->
    it "should call setState with existing provisions", ->
      makeTestService()

      subscriber = new TestSubscriber

      assert.equal(subscriber.getState().testProvision, "testProvision")

    it "should update subscriber state with new provisions", ->
      subscriber = new TestSubscriber

      assert.equal subscriber.getState().testProvision, undefined

      makeTestService()

      assert.equal subscriber.getState().testProvision, "testProvision"

    it "should ignore subscribers without subscribe field", ->
      dependencyManager.addSubscriber {}

  describe "updating fields", ->
    it "should propagate update to all subscribers", ->
      subscriber = new TestSubscriber
      subscriber2 = new TestSubscriber

      makeTestService()

      assert.equal subscriber.getState().testProvision, "testProvision"
      assert.equal subscriber2.getState().testProvision, "testProvision"

  describe "removing subscribers", ->
    it "should no longer propagate updates to removed subscribers", ->
      subscriber = new TestSubscriber

      makeTestService()

      assert.equal subscriber.getState().testProvision, "testProvision"

      dependencyManager.removeSubscriber subscriber

      makeTestService "testProvision2"

      assert.equal subscriber.getState().testProvision, "testProvision"
