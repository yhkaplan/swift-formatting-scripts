#!/bin/bash

file_path="$1"

# add check to make sure folder doesn't contain git folder

swiftformat --disable indent,consecutiveSpaces,trailingSpace,numberFormatting,blankLinesAtEndOfScope,blankLinesAtStartOfScope,strongOutlets,unusedArguments,hoistPatternLet,sortedImports,spaceAroundGenerics,trailingClosures,trailingCommas "$file_path"
