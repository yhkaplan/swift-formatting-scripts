#!/usr/bin/swift

import Foundation

let launchPath = "/usr/bin/env"

@discardableResult
func shell(_ command: String) -> Int32 {
    let args = command.components(separatedBy: " ")

    let process = Process()
    process.launchPath = launchPath
    process.arguments = args
    process.launch()
    process.waitUntilExit()

    return process.terminationStatus
}

func pipeOut(_ command: String) -> (Process, Pipe) {
    let args = command.components(separatedBy: " ")
    let pipe = Pipe()
    let process = Process()

    process.launchPath = launchPath
    process.arguments = args
    process.standardOutput = pipe

    return (process: process, pipe: pipe)
}

func pipeIn(_ command: String, pipe: Pipe) -> Process {
    let args = command.components(separatedBy: " ")
    let process = Process()

    process.launchPath = launchPath
    process.arguments = args
    process.standardInput = pipe

    return process
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
var configFile: String?
var shouldRunSwiftlint = true
var shouldRunSwiftFormat = true

let args = ProcessInfo.processInfo.arguments
args.enumerated().forEach { index, arg in
    switch arg {
    case "--path":
        filePath = args[index + 1]
    case "-p":
        filePath = args[index + 1]

    case "--config":
        configFile = args[index + 1]
    case "-c":
        configFile = args[index + 1]

    case "--swiftlint-only":
        shouldRunSwiftFormat = false
    case "-sl":
        shouldRunSwiftFormat = false

    case "--swiftformat-only":
        shouldRunSwiftlint = false
    case "-sf":
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

guard shouldRunSwiftlint else { exit(1) }

guard let configFile = configFile else {
    print("Missing --config/-c flag"); exit(1)
}

print("Running Swiftlint Autocorrect")
// Must call Swiftlint recursively on each swift file in filePath
let (process1, pipe) = pipeOut("find \(filePath) -type f -print0")//-name \\*.swift
let process2 = pipeIn("xargs -0 echo", pipe: pipe)//swiftlint autocorrect --config \(configFile) --path", pipe: pipe)

let outputPipe = Pipe()
process2.standardOutput = outputPipe

process1.launch()
// process1.waitUntilExit()
process2.launch()
process2.waitUntilExit()

let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

print(output ?? "error")
