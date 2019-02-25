# format.swift

> Format all the things

# format-only.swift

> Select certain SwiftFormat rule to format with

This is a convenient script to run both Swiftformat and Swiftlint.

# auto-add-mark.rb

> Add `// MARK: - {protocol name}` above extensions conforming to protocols

# Githooks

### post-checkout & post-merge

Run `pod install` and `rome download` after checkout and merge when needed.

### pre-commit

Format changed Swift files and add call auto-add-mark.rb

## Setting up

`brew install fd` (a super-performant Rust version of find)

## Usage

## Customizing for your needs

These scripts are just a starting point for your own projects. Feel free to choose your own rules and configurations! Also, I recommend managing Swiftlint and Swiftformat versions because new rules appear often. One solution is [Mint](mint-url....). Included in this repo is also a pre-commit git hook to automatically format changed/added files.

## TODO

- [ ] Add --help/-h arguments
