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

// TODO: Move these to Swiftformat config file
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
var configFile: String?
var shouldRunSwiftlint = true
var shouldRunSwiftFormat = true

let args = ProcessInfo.processInfo.arguments
args.enumerated().forEach { index, arg in
    switch arg {
    case "--path", "-p":
        filePath = args[index + 1]

    case "--config", "-c":
        configFile = args[index + 1]

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
    print("Running Swiftformat")
    shell("swiftformat --disable \(disabledRules.joined(separator: ",")) \(filePath)")
}

guard shouldRunSwiftlint else { exit(0) }

guard let configFile = configFile else {
    print("Missing --config/-c flag"); exit(1)
}

print("Running Swiftlint Autocorrect")
shell("fd . -0 --full-path \(filePath) -e swift -x swiftlint autocorrect --config \(configFile) --path")
