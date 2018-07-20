#!/usr/bin/swift

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

let disabledRules: [String] = [
    "consecutiveSpaces",
    "trailingSpace",
    "numberFormatting",
    "blankLinesAtEndOfScope",
    "blankLinesAtStartOfScope",
    "strongOutlets",
    "unusedArguments",
    "hoistPatternLet",
    "sortedImports",
    "spaceAroundGenerics",
    "trailingClosures",
    "trailingCommas"
]

var filePath: String?

let args = ProcessInfo.processInfo.arguments
args.enumerated().forEach { index, arg in
    switch arg {
    case "--path":
        filePath = args[index + 1]
    case "-p":
        filePath = args[index + 1]
    case "--config":
        filePath = args[index + 1]
    case "-c":
        filePath = args[index + 1]
    default:
        break
    }
}

guard let filePath = filePath else { print("Missing --path/-p flag"); exit(1) }

print("Running Swiftformat")
shell("swiftformat --disable \(disabledRules.joined(separator: ",")) \(filePath)")

guard let inputFile = inputFile else { print("Missing --config/-c flag"); exit(1) }

print("Running Swiftlint Autocorrect")
shell("swiftlint autocorrect --path \(filePath) --use-script-input-files \(inputFile)")
