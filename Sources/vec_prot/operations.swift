
import Swift

extension MySIMD {
  /// The valid indices for subscripting the vector.
  @_transparent
  public var indices: Range<Int> {
    return 0 ..< scalarCount
  }
}

extension MySIMD where Scalar: FixedWidthInteger {
  @_transparent
  public static func &+(lhs: Self, rhs: Self) -> Self {
    if lhs.hasVectorRepr {
      return Self.add(lhs, rhs)
    }
    var result = Self()
    for i in result.indices { result[i] = lhs[i] &+ rhs[i] }
    return result
  }
}
