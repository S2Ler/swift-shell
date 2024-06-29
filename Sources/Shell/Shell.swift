import Foundation

internal extension Pipe {
  func writeAndClose(_ string: String) {
    fileHandleForWriting.write(Data(string.utf8))
    fileHandleForWriting.closeFile()
  }
}

public protocol ShellArgumentConvertible: Sendable {
  var shellArgument: String { get }
}

public let shell: Shell = .init()

public struct Shell: Sendable {
  public final class Command {
    fileprivate var rawCommand: String = ""
    public init() {}
    @discardableResult
    public func append(_ string: String) -> Command {
      rawCommand.append(string)
      return self
    }
    @discardableResult
    public func append(argument: ShellArgumentConvertible) -> Command {
      rawCommand.append(argument.shellArgument)
      return self
    }
  }

  public struct Configuration: Sendable {
    public let shellPath: String
    public let shellRunCommandParameter: String

    public init(shellPath: String, shellRunCommandParameter: String) {
      self.shellPath = shellPath
      self.shellRunCommandParameter = shellRunCommandParameter
    }

    public static var bash: Configuration {
      .init(shellPath: "/bin/bash", shellRunCommandParameter: "-c")
    }

    public static var sh: Configuration {
      .init(shellPath: "/bin/sh", shellRunCommandParameter: "-c")
    }
  }

  public enum ShellError: LocalizedError {
    case standardError(String)

    public var errorDescription: String? {
      switch self {
      case .standardError(let string):
        return string
      }
    }
  }

  public let configuration: Configuration

  public init(configuration: Configuration = .bash) {
    self.configuration = configuration
  }

  @discardableResult
  public func run(
    _ function: String,
    arguments: ShellArgumentConvertible...,
    at path: String? = nil,
    input: Input? = nil,
    environmentVariables: [String: String]? = nil
  ) async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      let task = Process()
      task.executableURL = URL(fileURLWithPath: configuration.shellPath)
      let command: Command = .init()

      if let path = path {
        task.currentDirectoryURL = URL(fileURLWithPath: path, isDirectory: true)
      }
      command.append(function)
      command.append(" ")
      command.append(argument: arguments)

      task.arguments = [configuration.shellRunCommandParameter, command.rawCommand]
      task.environment = environmentVariables

      let outputPipe = Pipe()
      nonisolated(unsafe) var outputData = Data()

      outputPipe.fileHandleForReading.readabilityHandler = { handler in
        outputData.append(handler.availableData)
      }

      let errorPipe = Pipe()
      nonisolated(unsafe) var errorData = Data()
      errorPipe.fileHandleForReading.readabilityHandler = { handler in
        errorData.append(handler.availableData)
      }

      task.standardOutput = outputPipe
      task.standardInput = input?.processInput
      task.standardError = errorPipe
      task.terminationHandler = { process in
        if task.terminationStatus == 0 {
          continuation.resume(returning: String(data: outputData, encoding: .utf8) ?? "")
        }
        else {
          continuation.resume(throwing: ShellError.standardError(String(data: errorData, encoding: .utf8)!))
        }
      }

      do {
        try task.run()
        task.waitUntilExit()
      }
      catch {
        continuation.resume(throwing: error)
      }
    }
  }

  @discardableResult
  public func run(
    _ command: String,
    at path: String,
    input: Input? = nil,
    environmentVariables: [String: String]? = nil
  ) async throws -> String {
    let components = command.components(separatedBy: " ")
    let parsedCommand = components[0]
    let arguments: [ShellArgumentConvertible] = Array(components.dropFirst())

    return try await run(parsedCommand,
                         arguments: arguments,
                         at: path,
                         input: input,
                         environmentVariables: environmentVariables)
  }
}

extension String: ShellArgumentConvertible {
  public var shellArgument: String { "\"\(self)\"" }
}

extension Array: ShellArgumentConvertible where Element == ShellArgumentConvertible {
  public var shellArgument: String {
    self
      .map(\.shellArgument)
      .joined(separator: " ")
  }
}
