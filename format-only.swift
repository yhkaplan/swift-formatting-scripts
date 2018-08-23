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

func formatOutput(_ output: String, excluding excludedWord: String) -> String {
    let formattedSubstring = output
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "\(excludedWord)\n", with: "")
        .replacingOccurrences(of: "(disabled)", with: "")
        .replacingOccurrences(of: "\n", with: ",")
        .replacingOccurrences(of: ",,", with: "")
        .dropFirst() // Drop initial comma

    return String(formattedSubstring)
}

var filePath: String?
var rule: String?
var isVerbose = false

let args = ProcessInfo.processInfo.arguments
args.enumerated().forEach { index, arg in
    switch arg {
    case "--path", "-p":
        filePath = args[index + 1]

    case "--rule", "-r":
        rule = args[index + 1]

    case "--verbose", "-v":
        isVerbose = true

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

var disabledRules = formatOutput(output, excluding: rule)

// Address case when last rule specified
if let last = disabledRules.last, last  == "," {
    disabledRules = String(disabledRules.dropLast())
}

if isVerbose {
    print(
        """
        Running rule: \(rule)

        Disabling rules: \(disabledRules)
        """
    )
}

shellOut("swiftformat \(filePath) --disable \(disabledRules)")
