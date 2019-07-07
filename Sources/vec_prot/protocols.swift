
import Swift

public protocol MySIMDStorage {
  associatedtype Scalar
  var scalarCount: Int { get }
  init()
  subscript(index: Int) -> Scalar { get set }

  associatedtype HasVectorTy = Never
  static var hasVectorRepresentation: Bool { get }
}

extension MySIMDStorage {
  @_alwaysEmitIntoClient
  public var scalarCount: Int {
    return Self().scalarCount
  }

  static public var hasVectorRepresentation: Bool {
    @_transparent get { return false }
  }
}

// NOTE: This is not a public protocol on purpose!
public protocol LLVMVector {
  associatedtype Scalar
}

public protocol MySIMDVectorStorage : MySIMDStorage {
  associatedtype Vector : LLVMVector where Vector.Scalar == Scalar
}

extension MySIMDVectorStorage {
  public typealias HasVectorTy = Bool
  public var hasVectorRepresentation: Bool {
    @_transparent get { return true }
  }
}

/// A type that can be used as an element in a MySIMD vector.
public protocol MySIMDScalar {
  associatedtype MySIMD4Storage: MySIMDStorage where MySIMD4Storage.Scalar == Self
}

public protocol MySIMD : MySIMDStorage {}

extension MySIMD {
  /// The valid indices for subscripting the vector.
  @_transparent
  public var indices: Range<Int> {
    return 0 ..< scalarCount
  }
}

@_fixed_layout
public struct MySIMD4<Scalar> : MySIMD where Scalar : MySIMDScalar {
  public var _storage : Scalar.MySIMD4Storage

  @_transparent
  public var scalarCount: Int {
    return 4
  }

  @_transparent
  public init() {
    _storage = Scalar.MySIMD4Storage()
  }

  /// Accesses the scalar at the specified position.
  public subscript(index: Int) -> Scalar {
    @_transparent get {
      return _storage[index]
    }
    @_transparent set {
      _storage[index] = newValue
    }
  }
}
