import XCTest
@testable import Shell

@_silgen_name("swift_task_runAndBlockThread")
public func runAsyncAndBlock(_ asyncFun: @escaping () async -> ())

func runThrowingAsyncAndBlock(_ asyncFun: @escaping () async throws -> ()) throws {
  var throwedError: Error?
  runAsyncAndBlock {
    do {
      try await asyncFun()
    }
    catch {
      throwedError = error
    }
  }

  if let error = throwedError {
    throw error
  }
}

final class ShellTests: XCTestCase {
  func testSimpleOutput() throws {
    try runThrowingAsyncAndBlock {
      let actual = try await shell.run("pwd")
      XCTAssertEqual(actual, "/private/tmp\n")
    }
  }

  func testNonDefaultShell() throws {
    try runThrowingAsyncAndBlock {
      let shell = Shell(configuration: .sh)
      let actual = try await shell.run("pwd")
      XCTAssertEqual(actual, "/private/tmp\n")
    }
  }

  func testPbCopy() throws {
    try runThrowingAsyncAndBlock {
      let expected = "Hello World"
      try await shell.run("pbcopy", input: .string(expected))
      let actual = try await shell.run("pbpaste")
      XCTAssertEqual(expected, actual)
    }
  }

  func testLsList() throws {
    try runThrowingAsyncAndBlock {
      var output = try await shell.run("ls -la", at: "/")
      XCTAssert(output.contains("Volumes"))

      output = try await shell.run("ls", arguments: "-la", at: "/")
      XCTAssert(output.contains("Volumes"))
    }
  }

  func testLaunchPerformance() throws {
    measure {
      try! runThrowingAsyncAndBlock {
        try await shell.run("uptime")
      }
    }
  }
}

