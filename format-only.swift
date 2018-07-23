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

func shellOut(_ command: String) -> Pipe {
    let args = command.components(separatedBy: " ")

    let process = Process()
    let stdout = Pipe()
    process.standardOutput = stdout
    process.launchPath = launchPath
    process.arguments = args
    process.launch()
    process.waitUntilExit()

    return stdout
}

var filePath: String?

let args = ProcessInfo.processInfo.arguments
args.enumerated().forEach { index, arg in
    switch arg {
    case "--path":
        filePath = args[index + 1]
    case "-p":
        filePath = args[index + 1]

    default:
        break
    }
}

guard let filePath = filePath else {
    print("Missing --path/-p flag"); exit(1)
}

let stdout = shellOut("swiftformat --rules")
let data = stdout.fileHandleForReading.readDataToEndOfFile()
guard let output = String(data: data, encoding: String.Encoding.utf8) else {
    print("Error: no output"); exit(1)
}

let delimitedRules = output
    .replacingOccurrences(of: " ", with: "")
    .replacingOccurrences(of: "\n", with: ",")

// Swift 4 has one-sided ranges
let beginning = ..<delimitedRules.index(delimitedRules.startIndex, offsetBy: 6)
let rawDisabledRules = delimitedRules
    .replacingCharacters(in: beginning, with: "")

let lastTwoChars = rawDisabledRules.index(rawDisabledRules.endIndex, offsetBy: -7)...
let disabledRules = rawDisabledRules
    .replacingCharacters(in: lastTwoChars, with: "")

print(disabledRules)
// shell("swiftformat --disable \(disabledRules) \(filePath)")
