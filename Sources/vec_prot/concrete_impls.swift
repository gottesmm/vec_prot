
import Swift

// Lets assume that int32 has the right representation, but int64 does not for
// our purposes.
extension Int32 : MySIMDScalar {
  @frozen
  @_alignment(16)
  public struct MySIMD4Storage: MySIMDVectorStorageImpl {
    public typealias Scalar = Int32
    public typealias Vector = Builtin.Vec4xInt32

    public var _value: Vector

    init(_ value: Vector) { _value = value }

    @_transparent
    public var scalarCount: Int {
      return 4
    }

    @_transparent
    public init() {
      _value = Builtin.zeroInitializer()
    }

    @_transparent
    public var vector: Vector { return _value }

    public subscript(index: Int) -> Int32 {
      @_transparent
      get {
        return Int32(Builtin.extractelement_Vec4xInt32_Int32(
          _value, Int32(truncatingIfNeeded: index)._value
        ))
      }
      @_transparent
      set {
        _value = Builtin.insertelement_Vec4xInt32_Int32_Int32(
          _value, newValue._value, Int32(truncatingIfNeeded: index)._value
        )
      }
    }
  }
}

// Lets assume that int64 has the right representation, but int64 does not for
// our purposes.
extension Int64 : MySIMDScalar {
  @frozen
  @_alignment(16)
  public struct MySIMD4Storage: MySIMDStorageImpl {
    public typealias Scalar = Int64

    public var _value: Builtin.Vec4xInt64

    @_transparent
    public var scalarCount: Int {
      return 4
    }

    @_transparent
    public init() {
      _value = Builtin.zeroInitializer()
    }

    public subscript(index: Int) -> Int64 {
      @_transparent
      get {
        return Int64(Builtin.extractelement_Vec4xInt64_Int32(
          _value, Int32(truncatingIfNeeded: index)._value
        ))
      }
      @_transparent
      set {
        _value = Builtin.insertelement_Vec4xInt64_Int64_Int32(
          _value, newValue._value, Int32(truncatingIfNeeded: index)._value
        )
      }
    }
  }
}
