@testable import Bankside
import Foundation
import Quick
import Nimble

struct FactorySpecStruct {
  let attributes: [String: Any]
  init(attributes: [String: Any]) {
    self.attributes = attributes
  }
}

class FactorySpec: QuickSpec {

  override func spec() {
    var factory: Factory<FactorySpecStruct>!
    beforeEach {
      Counter.defaultCounter.reset()
      factory = Factory({ FactorySpecStruct(attributes: $0) })
    }

    describe("#uuid(key)") {
      it("defines an UUID attribute") {
        _ = factory.uuid("id")
        let attributes = factory.attributes([:], options: [:])
        expect(attributes["id"]).notTo(beNil())
        expect(attributes["id"] is String).to(equal(true))
      }
    }

    describe("#sequence(key)") {
      beforeEach {
        _ = factory.sequence("id")
      }

      it("defines attribute") {
        let attributes = factory.attributes([:], options: [:])
        expect(attributes["id"] as? Int).to(equal(1))
      }

      it("increments attribute value") {
        let _ = factory.attributes([:], options: [:])
        let attributes = factory.attributes([:], options: [:])
        expect(attributes["id"] as? Int).to(equal(2))
      }
    }

    describe("#sequence(key, closure)") {
      it("defines attribute") {
        _ = factory.sequence("id") { "id: \($0)" }
        let attributes = factory.attributes([:], options: [:])
        expect(attributes["id"] as? String).to(equal("id: 1"))
      }
    }

    describe("#attr(key, value)") {
      it("defines attribute") {
        _ = factory.attr("id", value: "lol")
        let attributes = factory.attributes([:], options: [:])
        let id = attributes["id"] as! String
        expect(id).to(equal("lol"))
      }
    }

    describe("#attr(key, closure)") {
      it("defines attribute") {
        _ = factory.attr("id") { _ in "lol" }
        let attributes = factory.attributes([:], options: [:])
        let id = attributes["id"] as! String
        expect(id).to(equal("lol"))
      }

      it("passes in options") {
        waitUntil(timeout: 5) { done in
          _ = factory.attr("id") { options in
            expect(options["value"]!).to(equal(true))
            defer { done() }
            return "hey"
          }
          _ = factory.attributes([:], options: ["value": true])
        }
      }
    }

    describe("#option(key, value)") {
      beforeEach {
        _ = factory.option("store", value: true)
      }

      it("defines option") {
        let options = factory.options([:])
        expect(options["store"]).to(equal(true))
      }

      it("overwrites option") {
        let options = factory.options(["store": false])
        expect(options["store"]).to(equal(false))
      }
    }

    describe("#transform(attribute, closure)") {
      context("matching attribute") {
        beforeEach {
          _ = factory.attr("account", value: NSUUID().uuidString)
          _ = factory.transform("account", closure: { ["account_id": $0] })
        }
        it("transforms attribute into another attribute") {
          let attributes = factory.attributes([:], options: [:])
          expect(attributes["account_id"]).notTo(beNil())
        }

        it("removes original attribute") {
          let attributes = factory.attributes([:], options: [:])
          expect(attributes["account"]).to(beNil())
        }
      }
      context("not matching attribute") {
        beforeEach {
          _ = factory.transform("account", closure: { _ in ["account_id": NSUUID().uuidString] })
        }

        it("refrains from invoking if the attribute doesn’t exist") {
          let attributes = factory.attributes([:], options: [:])
          expect(attributes["account"]).to(beNil())
        }
      }

    }

    describe("#after(callback)") {
      it("invokes callback when calling `build()`") {
        waitUntil(timeout: 5) { done in
          _ = factory.after { item, options in
            done()
          }
          _ = factory.build()
        }
      }

      it("passes in options") {
        waitUntil(timeout: 5) { done in
          _ = factory.after { item, options in
            expect(options["works"]!).to(equal(true))
            done()
          }
          _ = factory.build(options: ["works": true])
        }
      }

    }
  }

}
