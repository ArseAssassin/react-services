Provision = require "../src/Provision"

describe "Provision", ->
  describe "id", ->
    it "should reuse the same id for an object", ->
      provision = Provision.create({})()
      provision.id().must.eql provision.id()

    it "should create a new id for new object", ->
      Provision.create({})().id().must.not.eql Provision.create({})().id()
