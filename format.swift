#!/usr/bin/env swift

/* fd is needed
   brew install fd */
import Foundation

@discardableResult
func shell(_ command: String) -> Int32 {
    let args = command.components(separatedBy: " ")

    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = args
    process.launch()
    process.waitUntilExit()

    return process.terminationStatus
}

var filePath: String?

var swiftLintConfig = ".swiftlint.autocorrect.yml"
var swiftFormatConfig = ".swiftformat"

var shouldRunSwiftlint = true
var shouldRunSwiftFormat = true

let args = ProcessInfo.processInfo.arguments
args.enumerated().forEach { index, arg in
    switch arg {
    case "--path", "-p":
        filePath = args[index + 1]

    case "--swiftlint-config", "-slc":
        swiftLintConfig = args[index + 1]

    case "--swiftformat-config", "-sfc":
        swiftFormatConfig = args[index + 1]

    case "--swiftlint-only", "-sl":
        shouldRunSwiftFormat = false

    case "--swiftformat-only", "-sf":
        shouldRunSwiftlint = false

    default:
        break
    }
}

guard let filePath = filePath else {
    print("Missing --path/-p flag"); exit(1)
}

if shouldRunSwiftFormat {
    let swiftformat = "Pods/SwiftFormat/CommandLineTool/swiftformat"
    shell("\(swiftformat) \(filePath) --config \(swiftFormatConfig)")
}

guard shouldRunSwiftlint else { exit(0) }

print("Running Swiftlint Autocorrect")

let swiftlint = "Pods/SwiftLint/swiftlint"
let isSingleFile = filePath.hasSuffix(".swift")

if isSingleFile {
    shell("\(swiftlint) autocorrect --config \(swiftLintConfig) --path \(filePath)")
} else {
    shell("fd . -0 --full-path \(filePath) -e swift -x \(swiftlint) autocorrect --config \(swiftLintConfig) --path")
}
