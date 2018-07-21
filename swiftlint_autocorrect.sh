
find \(filePath) -type f -print0 -name \*.swift \
    | xargs -0 swiftlint autocorrect --config \(configFile) --path

