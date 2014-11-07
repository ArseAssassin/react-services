Queue = require "../src/Queue"
assert = require "assert"

describe "Queue", ->
  beforeEach ->
    @queue = Queue.create()

  it "should publish messages", ->
    @queue.publish("message")
    @queue.flush().must.eql(["message"])

  it "should return empty list after flushing", ->
    @queue.publish("message")
    @queue.flush()
    @queue.flush().must.eql([])
