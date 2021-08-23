import XCTest
@testable import Shell

final class ShellTests: XCTestCase {
  func testSimpleOutput() async throws {
    let actual = try await shell.run("pwd")
    XCTAssertEqual(actual, "/private/tmp\n")
  }

  func testNonDefaultShell() async throws {
    let shell = Shell(configuration: .sh)
    let actual = try await shell.run("pwd")
    XCTAssertEqual(actual, "/private/tmp\n")
  }

  func testPbCopy() async throws {
    let expected = "Hello World"
    try await shell.run("pbcopy", input: .string(expected))
    let actual = try await shell.run("pbpaste")
    XCTAssertEqual(expected, actual)
  }

  func testLsList() async throws {
    var output = try await shell.run("ls -la", at: "/")
    XCTAssert(output.contains("Volumes"))

    output = try await shell.run("ls", arguments: "-la", at: "/")
    XCTAssert(output.contains("Volumes"))
  }

  func testSimctlList() async throws {
    let output = try await shell.run("xcrun simctl list -j")
    print(output)
  }
}

