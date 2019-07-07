
import Swift

public struct HasVectorImpl<T> {
  public init() {}
  public var value: Bool {
    @_transparent get {
      return false
    }
  }
}

extension HasVectorImpl where T : MySIMDVectorStorage {
  public init() {}
  public var value: Bool {
    @_transparent get {
      return true
    }
  }
}

//  Implementations of integer operations. These should eventually all
//  be replaced with @_semantics to lower directly to vector IR nodes.
extension MySIMD where Scalar: FixedWidthInteger {
  @_transparent
  public static func &+(lhs: Self, rhs: Self) -> Self {
    // This should always reduce appropriately.
    if Self.hasVectorRepresentation {
      print("==> VECTOR")
    } else {
      print("==> SCALAR")
    }

    return Self()
  }
}
