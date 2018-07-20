#!/bin/bash/env swift

import Foundation

@discardableResult
func shell(_ command: String) -> Int32 {
    let args = command.split(" ")

    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = args
    process.launch()
    process.waitUntilExit()

    return process.terminationStatus
}

let disabledRules: [String] = [

]

guard let path = ProcessInfo.processInfo.arguments.first else {
    print("File path not contained")
    exit(1)
}

let exitStatus = shell("swiftformat --disable \(disabledRules.join(with: ",") \(path)")
print(exitStatus)
