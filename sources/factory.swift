/// The `Factory` class is a generic, that is the main class for creating a 
/// fixtures using Bankside. It provides an easy API for defining default 
/// attributes and options that allows you to change how you generate the data.

open class Factory<T> {

  public typealias CreateClosure = (_ attributes: [String: Any]) -> T
  public typealias AttributeClosure = (_ options: [String: Bool]) -> Any
  public typealias OptionClosure = () -> Bool
  public typealias AfterClosure = (_ item: T, _ options: [String: Bool]) -> Void
  public typealias SequenceClosure = (Int) -> Any
  public typealias TransformClosure = (_ value: Any) -> [String: Any]

  let create: CreateClosure
  var attributes: [String: AttributeClosure] = [:]
  var options: [String: OptionClosure] = [:]
  var transforms: [String: TransformClosure] = [:]
  var after: [AfterClosure] = []

  /// Creates a new factory
  ///
  /// - parameter create: a closure that converts the generated attributes into
  //    the model.
  public init(_ create: @escaping CreateClosure) {
    self.create = create
  }

  /// Defines an attribute that has a random UUID String assign to it.
  ///
  /// - parameter key: the key to set a UUIDv5
  /// - returns: It self
  open func uuid(_ key: String) -> Self {
    _ = self.attr(key) { _ in
      return UUID().uuidString
    }
    return self
  }

  /// Defines an attribute that will auto-increment every time it gets 
  /// generated, useful for identifiers you want to be unique. The sequence 
  /// will be unique per factory.
  ///
  /// Supports an optional closure, if provided, the closure’s result will be 
  /// used as the attribute value. The sequence value, will be passed in as the 
  /// first argument. Useful if you want predictable unique string values.
  ///
  /// - parameter key: attribute name
  /// - parameter closure: optional closure, its result will be used as the 
  ///   attribute value
  /// - returns: It self
  open func sequence(_ key: String, closure: SequenceClosure? = nil) -> Self {
    _ = self.attr(key) { _ in
      let sequence = Counter.defaultCounter.increment()
      if let closure = closure {
        return closure(sequence)
      }
      return sequence
    }
    return self
  }

  /// Defines an attribute
  /// 
  /// - parameter key: attribute name
  /// - parameter value: attribute value
  /// - returns: It self
  open func attr(_ key: String, value: Any) -> Self {
    self.attributes[key] = { _ in value }
    return self
  }

  /// Defines an attribute, that uses the passed in closure to generate the 
  /// value, it will be invoked everytime `build` is called.
  ///
  /// - parameter key: attribute name
  /// - parameter closure: closure to generate the attribute value
  /// - returns: It self
  open func attr(_ key: String, closure: @escaping AttributeClosure) -> Self {
    self.attributes[key] = closure
    return self
  }

  /// Defines an option that will be available when creating dynamic attributes,
  /// and in `after` callbacks.
  ///
  /// - parameter key: attribute name
  /// - parameter value: option value, if this is an `OptionClosure` it will be 
  ///   invoked instead of returned
  /// - returns: It self
  open func option(_ key: String, value: @autoclosure @escaping () -> Bool) -> Self {
    self.options[key] = value
    return self
  }

  /// Adds a callback that will be invoked after the model is created, and 
  /// before it is return in by the `build` function.
  ///
  /// - parameter callback: callback to be invoked right after creating the 
  ///   object
  /// - returns: It self
  open func after(_ callback: @escaping AfterClosure) -> Self {
    self.after.append(callback)
    return self
  }

  /// A transform, transforms one attribute into a set of other attributes.
  /// Transforms only gets applied iff the attribute exist. The original
  /// attribute gets removed, and the return value get merged with compiled
  /// attributes. Transforms are always applied after all attributes are
  /// compiled.
  ///
  /// - parameter attribute: the name of the attribute to transform
  /// - parameter closure: closure that will get invoked in the build sequence.
  ///   The closure will be invoked with the attribute value. The dictionary
  ///   return value, will be merged with the attribute, will
  /// - returns: it self
  open func transform(_ attribute: String, closure: @escaping TransformClosure) -> Self {
    self.transforms[attribute] = closure
    return self
  }

  /// Builds the object
  ///
  /// - parameter attributes: additional attributes
  /// - parameter options: additional options
  /// - returns: The built object
  open func build(_ attributes: [String: Any] = [:], options: [String: Bool] = [:]) -> T {
    let options = self.options(options)
    let attributes = self.attributes(attributes, options: options)
    let item = self.create(attributes)
    for callback in self.after {
      callback(item, options)
    }
    return item
  }

  func attributes(_ attributes: [String: Any], options: [String: Bool]) -> [String: Any] {
    var attributes = attributes
    for (key, value) in self.attributes where attributes[key] == nil {
      attributes[key] = value(options)
    }

    for (key, value) in self.transforms {
      if let transformValue = attributes.removeValue(forKey: key) {
        attributes += value(value: transformValue)
      }
    }

    return attributes
  }

  func options(_ options: [String: Bool]) -> [String: Bool] {
    var options = options
    for (key, value) in self.options where options[key] == nil {
      options[key] = value()
    }
    return options
  }

}
