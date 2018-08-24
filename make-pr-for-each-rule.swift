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

func formatOutput(_ output: String) -> [Rule] {
    let formattedSubstring = output
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "(disabled)", with: "")
        .replacingOccurrences(of: "\n", with: ",")
        .replacingOccurrences(of: ",,", with: "")
        .dropFirst() // Drop initial comma

    return String(formattedSubstring)
        .components(separatedBy: ",")
        .map(Rule.init)
}

// list and format rules
guard let output = shellOut("swiftformat --rules") else {
    print("Error: no output"); exit(1)
}

// make array from rules
// remove disabled rules from .swiftformat file using set?
let rules = Set<formatOutput(output)>
    .subtract(disabledRules)

rules.forEach { rule in
    print("Formatting \(rule)"
    let branchName = "feature/\(ruleName)") // TODO: Does / mark work in strings?

    shellOut("git checkout develop")
    shellOut("git checkout -b \(branchName)")

    shellOut("format-only.swift -p {path from parameter}")

    shellOut("git commit -m Run_\(rule)_on_\(path)")
    shellOut("git push -u origin \(branchName)")
    shellOut("git pull-request -m {pr_name}")
}

print("Finished!")
