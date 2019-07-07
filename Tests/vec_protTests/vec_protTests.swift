import XCTest
@testable import vec_prot

final class vec_protTests: XCTestCase {
  func testExample() {
    let x = MySIMD4<Int32>()
    let y = x &+ x
    print(y)
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
