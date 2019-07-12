
import Swift

// =============================================================================

// A `Never`-like type for default implementations and associated types
@frozen
public enum _SIMDNever {}

// =============================================================================

// Wraps around a concrete builtin SIMD vector type and uses builtin operations
public protocol _SIMDVector {
  static func add(_ lhs: Self, _ rhs: Self) -> Self

  // ...
}

extension _SIMDNever: _SIMDVector {
  public static func add(_ lhs: Self, _ rhs: Self) -> Self {}

  // ...
}

// =============================================================================

public protocol SIMDStorage {
  associatedtype Scalar: SIMDScalar

  associatedtype _Vector: _SIMDVector = _SIMDNever

  static var _hasVectorRepresentation: Bool { get }

  static var scalarCount: Int { get }

  var _vector: _Vector { get }

  var scalarCount: Int { get }

  init()

  init(_vector: _Vector)

  subscript(index: Int) -> Scalar { get set }
}

extension SIMDStorage {
  @_transparent
  public static var _hasVectorRepresentation: Bool {
    return false
  }

  public var _vector: _Vector {
    @inline(never)
    get {
      // Will never be called unless `_hasVectorRepresentation == true`,
      // in which case this implementation would be overriden in stdlib
      fatalError("""
        Error! Called default SIMDStorage._vector impl?! A SIMDStorage class
        overrides _hasVectorRepresentation to return true, but did not provide
        an implementation for this method as well!
        """)
    }
  }

  // Previously, the static `scalarCount` was defined in terms of this
  // property; also I think this property should be deprecated altogether
  public var scalarCount: Int {
    @_transparent
    get {
      return Self.scalarCount
    }
  }

  @inline(never)
  public init(_vector: _Vector) {
    // Will never be called unless `_hasVectorRepresentation == true`, in
    // which case this implementation would be overriden in stdlib
    fatalError("""
      Error! Called default SIMDStorage.init(_vector) impl?! A SIMDStorage class
      overrides _hasVectorRepresentation to return true, but did not provide an
      implementation for this method as well!
      """)
  }
}

extension _SIMDNever: SIMDStorage {
  public typealias Scalar = _SIMDNever

  public static var scalarCount: Int {
    @inline(never)
    get {
      switch Self() {}
    }
  }

  public subscript(index: Int) -> Scalar {
    @inline(never)
    get {
      switch self {}
    }
    set {}
  }

  @inline(never)
  public init() {
    fatalError("\(Self.self) cannot be instantiated")
  }
}

// =============================================================================

public protocol SIMDScalar {
  // ...

  associatedtype SIMD4Storage: SIMDStorage where SIMD4Storage.Scalar == Self

  // ...
}

extension _SIMDNever: SIMDScalar {
  // ...

  public typealias SIMD4Storage = _SIMDNever

  // ...
}

// =============================================================================

public protocol SIMD: SIMDStorage {
  associatedtype _InnerStorage : SIMDStorage where _InnerStorage._Vector == Self._Vector
  var _innerStorage: _InnerStorage { get set }
}

extension SIMD {
  public var indices: Range<Int> {
    @_transparent get {
      return 0 ..< scalarCount
    }
  }

  // ...

  @_transparent
  public var _vector: _Vector {
    return _innerStorage._vector
  }

  @_transparent
  public init(_vector: _Vector) {
    self.init()
    _innerStorage = _InnerStorage(_vector: _vector)
  }
}

extension SIMD where Scalar: FixedWidthInteger {
  //@_transparent
  public static func &+(lhs: Self, rhs: Self) -> Self {
    // We'll almost always be calling this on stdlib SIMD types, so this
    // branch is very likely in a generic context
    if _fastPath(Self._hasVectorRepresentation) {
      // Delegate to concrete operations on `Self._Vector`
      let lVec = lhs._vector
      let rVec = rhs._vector
      let result = Self._Vector.add(lVec, rVec)
      return Self(_vector: result)
    }

    // Slow fallback
    var result = Self()
    for i in result.indices { result[i] = lhs[i] &+ rhs[i] }
    return result

  }

  // ...
}

// =============================================================================

@frozen
public struct SIMD4<Scalar: SIMDScalar>: SIMD {
  public typealias _InnerStorage = Scalar.SIMD4Storage
  public typealias _Vector = _InnerStorage._Vector

  public var _innerStorage: _InnerStorage {
    @_transparent
    get { return _storage }
    @_transparent
    set { _storage = newValue }
  }

  public static var _hasVectorRepresentation: Bool {
    @_transparent get {
      return Scalar.SIMD4Storage._hasVectorRepresentation
    }
  }

  public static var scalarCount: Int {
    @_transparent get {
      return Scalar.SIMD4Storage.scalarCount
    }
  }

  public var _storage: Scalar.SIMD4Storage

  public subscript(index: Int) -> Scalar {
    @_transparent get {
      return self._storage[index]
    }
    @_transparent set {
      self._storage[index] = newValue
    }
  }

  @_transparent
  public init() {
    _storage = Scalar.SIMD4Storage()
  }

  // ...
}

// =============================================================================

extension Int32: SIMDScalar {
  @frozen
  public struct SIMD4Storage: SIMDStorage {
    public typealias Scalar = Int32

    @frozen
    @_alignment(16) // 4x4
    public struct _Vector: _SIMDVector, RawRepresentable {
      public var rawValue: Builtin.Vec4xInt32

      @_transparent
      public init(rawValue: RawValue) {
        self.rawValue = rawValue
      }

      @_transparent
      public static func add(_ lhs: Self, _ rhs: Self) -> Self {
        return Self(rawValue: Builtin.add_Vec4xInt32(lhs.rawValue, rhs.rawValue))
      }
    }

    public static var _hasVectorRepresentation: Bool {
      @_transparent get {
        return true
      }
    }

    public static var scalarCount: Int {
      @_transparent get {
        return 2
      }
    }

    public var _vector: _Vector

    public subscript(index: Int) -> Scalar {
      @_transparent get {
        return Int32(Builtin.extractelement_Vec4xInt32_Int32(
            _vector.rawValue,
            Int32(truncatingIfNeeded: index)._value
          ))
      }
      @_transparent set {
        _vector.rawValue = Builtin.insertelement_Vec4xInt32_Int32_Int32(
          _vector.rawValue,
          newValue._value,
          Int32(truncatingIfNeeded: index)._value
        )
      }
    }

    @_transparent
    public init() {
      _vector = Builtin.zeroInitializer()
    }

    @_transparent
    public init(_vector: _Vector) {
      self._vector = _vector
    }
  }
}
