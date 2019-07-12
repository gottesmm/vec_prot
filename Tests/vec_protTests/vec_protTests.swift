import XCTest
import simd
import vec_prot

public func addTest(_ x: vec_prot.SIMD4<Int32>, _ y: vec_prot.SIMD4<Int32>) -> vec_prot.SIMD4<Int32> {
  return x &+ x
}

public func addTest(_ x: vec_prot.SIMD4<Int64>, _ y: vec_prot.SIMD4<Int64>) -> vec_prot.SIMD4<Int64> {
  return x &+ x
}

final class vec_protTests: XCTestCase {
  func testWithVectors() {
    do {
      var x = vec_prot.SIMD4<Int32>()
      x[0] = 5
      x[1] = 6
      x[2] = 7
      x[3] = 8
      let y = addTest(x, x)
      for i in 0..<4 { print(y[i]) }
    }
  }

  func testWithOutVectors() {
    do {
      var x = vec_prot.SIMD4<Int64>()
      x[0] = 5
      x[1] = 6
      x[2] = 7
      x[3] = 8
      let y = addTest(x, x)
      for i in 0..<4 { print(y[i]) }
    }
  }

  static var allTests = [
    ("testWithOutVectors", testWithOutVectors),
    ("testWithVectors", testWithVectors),
  ]
}
