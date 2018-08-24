#!/usr/bin/env swift

import Foundation

let launchPath = "/usr/bin/env"
typealias Rule = String

@discardableResult
func shellOut(_ command: String) -> String? {
    let args = command.components(separatedBy: " ")

    let process = Process()
    let stdout = Pipe()
    process.standardOutput = stdout
    process.launchPath = launchPath
    process.arguments = args
    process.launch()
    process.waitUntilExit()

    let data = stdout.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8)
}

func formatOutput(_ output: String) -> Set<Rule> {
    let formattedSubstring = output
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "(disabled)", with: "")
        .replacingOccurrences(of: "\n", with: ",")
        .replacingOccurrences(of: ",,", with: "")
        .dropFirst() // Drop initial comma

    // Make substring into array of strings
    let ruleArray = String(formattedSubstring)
        .components(separatedBy: ",")

    return Set(ruleArray)
}

guard let output = shellOut("swiftformat --rules") else {
    print("Error: no output"); exit(1)
}

let disabledRules: Set = ["sortedImports"]

let rules = formatOutput(output)
    .subtracting(disabledRules)

rules.forEach { rule in
    print("Formatting \(rule)")
    let branchName = "feature/\(ruleName)") // TODO: Does / mark work in strings?

    shellOut("git checkout develop")
    shellOut("git checkout -b \(branchName)")

    shellOut("format-only.swift -p {path from parameter}")

    shellOut("git commit -m Run_\(rule)_on_\(path)")
    shellOut("git push -u origin \(branchName)")
    shellOut("git pull-request -m {pr_name}")
}

print("\nFinished!")
