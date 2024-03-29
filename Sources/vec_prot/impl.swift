
import Swift

// =============================================================================

// A `Never`-like type for default implementations and associated types
@frozen
public enum _SIMDNever {}

// A `Never`-like type for default implementations that provides a SIMDScalar
// based T for use in where requirements.
//
// This is necessary for the following code to properly compile:
//
// extension _SIMDGenericNever: _SIMDStorageWithOps {
//   public typealias Scalar = T
//   public typealias _InnerStorage = _SIMDGenericNever<T>
//   ...
// }
//
// Given that we want _InnerStorage.Scalar to equal specific Scalar values to
// appease the type checker. If one does not need this functionality, just pass
// _SIMDNever as the generic parameter since it is a SIMDScalar.
@frozen
public enum _SIMDGenericNever<T : SIMDScalar> {}

// =============================================================================

public protocol SIMDStorage {
  associatedtype Scalar: SIMDScalar

  associatedtype _InnerStorage: _SIMDStorageWithOps = _SIMDGenericNever<_SIMDNever> where _InnerStorage.Scalar == Self.Scalar

  static var _hasVectorRepresentation: Bool { get }

  static var scalarCount: Int { get }

  var _innerStorage: _InnerStorage { get set }

  var scalarCount: Int { get }

  init()

  init(_storage: _InnerStorage)

  subscript(index: Int) -> Scalar { get set }
}

extension SIMDStorage {
  @_transparent
  public static var _hasVectorRepresentation: Bool {
    return false
  }

  public var _innerStorage: _InnerStorage {
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
    set {
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
  public init(_storage: _InnerStorage) {
    // Will never be called unless `_hasVectorRepresentation == true`, in
    // which case this implementation would be overriden in stdlib
    fatalError("""
      Error! Called default SIMDStorage.init(_vector) impl?! A SIMDStorage class
      overrides _hasVectorRepresentation to return true, but did not provide an
      implementation for this method as well!
      """)
  }
}

public protocol _SIMDStorageWithOps : SIMDStorage {
  static func add(_ lhs: Self, _ rhs: Self) -> Self
}

extension _SIMDStorageWithOps {
  @_transparent
  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    fatalError("In default SIMDStorageWithOps add impl")
  }
}

extension _SIMDNever: _SIMDStorageWithOps {
  public typealias Scalar = _SIMDNever
  public typealias _InnerStorage = _SIMDNever

  public static func add(_ lhs: Self, _ rhs: Self) -> Self {}
  public static var scalarCount: Int {
    @inline(never)
    get {
      switch Self() {}
    }
  }

  public var _innerStorage: _InnerStorage {
    get {
      switch Self() {}
    }
    set {
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

extension _SIMDGenericNever: _SIMDStorageWithOps {
  public typealias Scalar = T
  public typealias _InnerStorage = _SIMDGenericNever<T>

  public static func add(_ lhs: Self, _ rhs: Self) -> Self {}

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

  public var _innerStorage: _InnerStorage {
    get {
      switch Self() {}
    }
    set {
    }
  }
}

// =============================================================================

public protocol SIMDScalar {
  // ...

  associatedtype SIMD4Storage: _SIMDStorageWithOps where SIMD4Storage.Scalar == Self

  // ...
}

extension _SIMDNever: SIMDScalar {
  // ...

  public typealias SIMD4Storage = _SIMDNever

  // ...
}

// =============================================================================

public protocol SIMD: SIMDStorage {
}

extension SIMD {
  public var indices: Range<Int> {
    @_transparent get {
      return 0 ..< scalarCount
    }
  }

  // ...

  @_transparent
  public init(_storage: _InnerStorage) {
    self.init()
    _innerStorage = _storage
  }
}

extension SIMD where Scalar: FixedWidthInteger {
  @_transparent
  public static func &+(lhs: Self, rhs: Self) -> Self {
    // We'll almost always be calling this on stdlib SIMD types, so this
    // branch is very likely in a generic context
    if _fastPath(Self._hasVectorRepresentation) {
      // Delegate to concrete operations on `Self._Vector`
      let lVec = lhs._innerStorage
      let rVec = rhs._innerStorage
      let result = Self._InnerStorage.add(lVec, rVec)
      return Self(_storage: result)
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

public protocol _SIMDVectorStorage : _SIMDStorageWithOps {
  // Must be a builtin type.
  associatedtype _Vector
}

// =============================================================================

extension Int32: SIMDScalar {
  @frozen
  public struct SIMD4Storage: _SIMDVectorStorage {
    public typealias Scalar = Int32
    public typealias _InnerStorage = _SIMDGenericNever<Scalar>
    public typealias _Vector = Builtin.Vec4xInt32

// ENABLE this for vector code.
#if !ENABLE_GENERIC_IMPL
    @_transparent
    public static func add(_ lhs: Self, _ rhs: Self) -> Self {
      return Self(_vector: Builtin.add_Vec4xInt32(lhs._vector, rhs._vector))
    }
#endif

    public static var _hasVectorRepresentation: Bool {
      @_transparent get {
        return true
      }
    }

    public static var scalarCount: Int {
      @_transparent get {
        return 4
      }
    }

    public var _vector: _Vector

    public subscript(index: Int) -> Scalar {
      @_transparent get {
        return Int32(Builtin.extractelement_Vec4xInt32_Int32(
            _vector,
            Int32(truncatingIfNeeded: index)._value
          ))
      }
      @_transparent set {
        _vector = Builtin.insertelement_Vec4xInt32_Int32_Int32(
          _vector,
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

extension Int64: SIMDScalar {
  @frozen
  public struct SIMD4Storage: _SIMDStorageWithOps {
    public typealias Scalar = Int64
    public typealias _InnerStorage = _SIMDGenericNever<Scalar>
    public typealias _Vector = Builtin.Vec4xInt64

    public static var _hasVectorRepresentation: Bool {
      @_transparent get {
        return false
      }
    }

    public static var scalarCount: Int {
      @_transparent get {
        return 4
      }
    }

    public var _vector: _Vector

    public subscript(index: Int) -> Scalar {
      @_transparent get {
        return Int64(Builtin.extractelement_Vec4xInt64_Int32(
            _vector,
            Int32(truncatingIfNeeded: index)._value
          ))
      }
      @_transparent set {
        _vector = Builtin.insertelement_Vec4xInt64_Int64_Int32(
          _vector,
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
