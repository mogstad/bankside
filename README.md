# Bankside

Bankside is a fixture generation tool. It’s useful for defining fixtures for tests. Inspired by [factory_girl](https://github.com/thoughtbot/factory_girl) and [Rosie.js](https://github.com/rosiejs/rosie)

## Usage

Bankside provides an easy API for defining default attributes and options that allows you to change how you generate the data. 

### Defining a factory

```swift
struct Account {
  let id: Int
  let name: String
  init(payload: [String: Any]) {
    self.id = payload["id"] as! Int
    self.name = payload["name"] as! String
  }
} 
```

```swift
import Bankside

let AccountFactory = Factory({ Account(payload: $0) })
  .sequence("id")
  .attr("name", "Walter White")
```

### Using a factory

```swift
let walter = AccountFactory.build()
let gustavo = AccountFactory.build(attributes: [
  "name": "Gustavo Fridge"
])
```

### Extentions

To keep your fixtures DRY it’s useful to extend the Factory class and add common or complex default attributes. Remember to return `self` to keep the API chainable.

```swift
extension Factory {

  func timestamp() -> Self {
    func date(options: [String: Any]) {
      return NSDate()
    }
    self.attr("created_at", closure: date)
    self.attr("updated_at", closure: date)
    return self
  }

}
```

In use: 

```swift 
let AccountFactory = Factory({ Account(payload: $0) })
  .sequence("id")
  .attr("name", "Walter White")
  .timestamps()
```

### Limitations

We don’t try to detect circular dependencies, you will just get a stack overflow if it happens. 

## Install

Requirements: 
- Bankside will be compatible with the lastest public release of Swift. Older releases will be available, but bug fixes won’t be issued. 
- A data structure that accepts a reflected data structure to populate its models.

### [Carthage](https://github.com/carthage/carthage)

1. Add `github "mogstad/bankside" ~> 0.1.0` to “Cartfile.private”
2. Run `carthage update`
3. Link Bankside with your test target
4. Create a new “Copy files” build phases, set ”Destination” to ”Frameworks”, add Bankside

### [CocoaPods](https://cocoapods.org)

Update your podfile:

1. Add `use_frameworks!` to your pod file[^1]
2. Add `pod "Bankside", "~> 0.1.0"` to your testing target
3. Update your dependencies by running `pod install`

[^1]:
Swift can’t be included as a static library, therefor it’s required to add `use_frameworks!` to your `podfile`. It will then import your dependeices as dynamic frameworks.
