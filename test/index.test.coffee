assert = require "assert"

index = require "../src/index"

describe "react-services", ->
  beforeEach ->
    index.clear()

  describe "clearing dependency manager", ->
    it "should clear existing subscribers", ->
      propagatedValue = null

      index.defineService "DependentService", (services) ->
        propagatedValue = services.test
        subscribe:
          test: "TestService#test"

      index.defineService "TestService", ->
        test: -> "hello"

      assert.equal propagatedValue, "hello"

      index.clear()

      index.defineService "TestService", ->
        test: -> "bye"

      assert.equal propagatedValue, "hello"


  describe "defining services", ->
    it "should manage dependencies between services", ->
      index.defineService "TestService", ->
        test: -> "hello"

      propagatedValue = null

      index.defineService "DependentTestService", (services) ->
        propagatedValue = services.test
        subscribe:
          test: "TestService#test"

      assert.equal propagatedValue, "hello"

  describe "getting provisions", ->
    it "should get up to date provision value", ->
      index.defineService "TestService", ->
        test: -> "hello"

      assert.equal index.getValue("TestService#test"), "hello"
