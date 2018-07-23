#!/usr/bin/swift

import Foundation

let launchPath = "/usr/bin/env"

@discardableResult
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

// TODO: specifying the last rule leaves an extra comma at the end
// TODO: Wrap string formatting in func
func formatOutput(_ output: String, excluding excludedWord: String) -> String {
    let delimited = output
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "\(excludedWord)\n", with: "")
        .replacingOccurrences(of: "(disabled)", with: "")
        .replacingOccurrences(of: "\n", with: ",")

    let beginning = ..<delimited.index(delimited.startIndex, offsetBy: 6)
    let trimmedStart = delimited
        .replacingCharacters(in: beginning, with: "")

    let lastTwoChars = trimmedStart.index(trimmedStart.endIndex, offsetBy: -7)...
    let trimmedEnd = trimmedStart
        .replacingCharacters(in: lastTwoChars, with: "")

    return trimmedEnd
}

var filePath: String?
var rule: String?

let args = ProcessInfo.processInfo.arguments
args.enumerated().forEach { index, arg in
    switch arg {
    case "--path":
        filePath = args[index + 1]
    case "-p":
        filePath = args[index + 1]

    case "--rule":
        rule = args[index + 1]
    case "-r":
        rule = args[index + 1]

    default:
        break
    }
}

guard let filePath = filePath else {
    print("Missing --path/-p flag"); exit(1)
}

guard let rule = rule else {
    print("Missing --rule/-r flag"); exit(1)
}

let stdout = shellOut("swiftformat --rules")
let data = stdout.fileHandleForReading.readDataToEndOfFile()

guard let output = String(data: data, encoding: String.Encoding.utf8) else {
    print("Error: no output"); exit(1)
}

let disabledRules = formatOutput(output, excluding: rule)
print(disabledRules)
// shellOut("swiftformat --disable \(disabledRules) \(filePath)")
