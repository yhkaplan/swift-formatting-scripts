#!/bin/bash/env swift

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

let args = ProcessInfo.processInfo.arguments

guard args.count > 4 else {
    print("File path not specified")
    exit(1)
}

let filePath = args[3]

let exitStatus = shell("swiftformat --disable \(disabledRules.joined(separator: ",")) \(filePath)")
print("\(exitStatus)")
