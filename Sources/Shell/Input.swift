import Foundation

public enum Input {
  case raw(Any)
  case string(String)

  internal var processInput: Any {
    switch self {
    case .raw(let rawInput):
      return rawInput
    case .string(let string):
      let pipe = Pipe()
      pipe.writeAndClose(string)
      return pipe
    }
  }
}
