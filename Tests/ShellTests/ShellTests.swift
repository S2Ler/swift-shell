import Testing
import Foundation

@testable import Shell

struct ShellTests {
  @Test func simpleOutput() async throws {
    let actual = try await shell.run("pwd")
    #expect(actual == "/private/tmp\n")
  }

  @Test func nonDefaultShell() async throws {
    let shell = Shell(configuration: .sh)
    let actual = try await shell.run("pwd")
    #expect(actual == "/private/tmp\n")
  }

  @Test func pbCopy() async throws {
    let expected = "Hello World"
    try await shell.run("pbcopy", input: .string(expected))
    let actual = try await shell.run("pbpaste")
    #expect(expected == actual)
  }

  @Test func lsList() async throws {
    var output = try await shell.run("ls -la", at: "/")
    #expect(output.contains("Volumes"))
    output = try await shell.run("ls", arguments: "-la", at: "/")
    #expect(output.contains("Volumes"))
  }

  @Test func simctlList() async throws {
    let output = try await shell.run("xcrun simctl list -j")
    #expect(output.contains("maxRuntimeVersionString"))
  }
}
