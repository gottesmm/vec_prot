
import Swift

/// A type that can be used as an element in a MySIMD vector.
public protocol MySIMDScalar {
  associatedtype MySIMD4Storage: MySIMDStorageImpl where MySIMD4Storage.Scalar == Self
}

public protocol MySIMDStorage {
  associatedtype Scalar : MySIMDScalar

  var scalarCount: Int { get }
  init()
  subscript(index: Int) -> Scalar { get set }

  var hasVectorRepr : Bool { get }
}

extension MySIMDStorage {
  @_alwaysEmitIntoClient
  public var scalarCount: Int {
    return Self().scalarCount
  }

  @_transparent
  public var hasVectorRepr : Bool { return false }
}

public protocol MySIMDStorageImpl : MySIMDStorage {
  static func add(_ lhs: Self, _ rhs: Self) -> Self
}

extension MySIMDStorageImpl {
  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    print(type(of: lhs))
    fatalError("Should never call this function!")
  }
}

// MG: Note how we constraint Vector.Scalar on Scalar here. We do not care about
// the actual value of Vector in MySIMDStorage since we will either fatalError
// in MySIMDStorage.init or return nil in getAsSIMD()
//
// NOTE: This subprotocol of MySIMDStorage _MUST BE INTERNAL_.
protocol MySIMDVectorStorageImpl : MySIMDStorageImpl {
  associatedtype Vector

  init(_ value: Vector)
  var vector : Vector { get }

  //static func add(lhs: Self, rhs: Self) -> Self

  var hasVectorRepr: Bool { get }
}

extension MySIMDVectorStorageImpl {
  @_transparent
  static func add(lhs: Self, rhs: Self) -> Self {
    fatalError("From MySIMDVectorStorage")
  }

  @_transparent
  public var hasVectorRepr: Bool { return true }
}

public protocol MySIMD : MySIMDStorageImpl {
}

@frozen
public struct MySIMD4<ScalarTy> : MySIMD where ScalarTy : MySIMDScalar {
  public var _storage : ScalarTy.MySIMD4Storage

  @_transparent
  public var scalarCount: Int {
    return 4
  }

  @_transparent
  public init() {
    _storage = ScalarTy.MySIMD4Storage()
  }

  /// Accesses the scalar at the specified position.
  public subscript(index: Int) -> ScalarTy {
    @_transparent get {
      return _storage[index]
    }
    @_transparent set {
      _storage[index] = newValue
    }
  }

  @_transparent
  public var hasVectorRepr : Bool { return _storage.hasVectorRepr }

  @_transparent
  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    var result = Self()
    result._storage = ScalarTy.MySIMD4Storage.add(lhs._storage, rhs._storage)
    return result
  }
}
