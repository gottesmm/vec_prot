import XCTest
import simd
import vec_prot

public func runTest1(_ x: MySIMD4<Int32>) -> MySIMD4<Int32> {
  return x &+ x &+ x &+ x
}

public func runTest1a(_ buffer: UnsafeBufferPointer<MySIMD4<Int32>>) -> MySIMD4<Int32> {
  var accum = MySIMD4<Int32>()
  for x in buffer {
    accum = accum &+ x
  }
  return accum
}

public func runTest2(_ x: MySIMD4<Int64>) -> MySIMD4<Int64> {
  return x &+ x &+ x &+ x
}


final class vec_protTests: XCTestCase {
  func testExample() {
    do {
      var x = MySIMD4<Int32>()
      x[0] = 5
      x[1] = 6
      x[2] = 7
      x[3] = 8
      let y = x &+ x
      for i in 0..<4 { print(y[i]) }
    }

/*
    do {
      var x = MySIMD4<Int64>()
      x[0] = 5
      x[1] = 6
      x[2] = 7
      x[3] = 8
      let y = x &+ x
      for i in 0..<4 { print(y[i]) }
    }
*/
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
