
import Swift

// Wrapper around Builtin.Vec4xInt32 for the purpose of adding conformances.
public struct Vec4xInt32 {
  public var _value : Builtin.Vec4xInt32

  @_transparent
  public init() {
    _value = Builtin.zeroInitializer()
  }
}

extension Vec4xInt32 : LLVMVector {
  public typealias Scalar = Int32
}

// Lets assume that int32 has the right representation, but int64 does not for
// our purposes.
extension Int32 : MySIMDScalar {
  @_fixed_layout
  @_alignment(16)
  public struct MySIMD4Storage: MySIMDVectorStorage {
    public typealias Scalar = Int32
    public typealias Vector = Vec4xInt32
    
    public var _value: Vector

    @_transparent
    public var scalarCount: Int {
      return 4
    }

    @_transparent
    public init() {
      _value = Vector()
    }

    public subscript(index: Int) -> Int32 {
      @_transparent
      get {
        return Int32(Builtin.extractelement_Vec4xInt32_Int32(
          _value._value, Int32(truncatingIfNeeded: index)._value
        ))
      }
      @_transparent
      set {
        _value._value = Builtin.insertelement_Vec4xInt32_Int32_Int32(
          _value._value, newValue._value, Int32(truncatingIfNeeded: index)._value
        )
      }
    }
  }
}

extension Float: MySIMDScalar {
  public typealias MySIMDStorageProtocol = MySIMDStorage

  /// Storage for a vector of four floating-point values.
  @_fixed_layout
  @_alignment(16)
  public struct MySIMD4Storage: MySIMDStorage {

    public var _value: Builtin.Vec4xFPIEEE32

    @_transparent
    public var scalarCount: Int {
      return 4
    }

    @_transparent
    public init() {
      _value = Builtin.zeroInitializer()
    }

    public subscript(index: Int) -> Float {
      @_transparent
      get {
        return Float(Builtin.extractelement_Vec4xFPIEEE32_Int32(
          _value, Int32(truncatingIfNeeded: index)._value
        ))
      }
      @_transparent
      set {
        _value = Builtin.insertelement_Vec4xFPIEEE32_FPIEEE32_Int32(
          _value, newValue._value, Int32(truncatingIfNeeded: index)._value
        )
      }
    }
  }
}
