require 'optparse'

args = {}
OptionParser.new do |opt|
  opt.on('--path FILE_PATH') { |o| args[:path] = o }
end.parse!

file_path = args[:path]

File.open(file_path, 'r+') do |file|
  contents = File.read(file)
  file_contains_newline_mark_format = contents =~ /^\n\/\/ MARK.*\n/

  if !file_contains_newline_mark_format
    edited_contents = contents.gsub(/^\nextension (.*): (.*) {/, "\n// MARK: - \\2\nextension \\1: \\2 {")
    file.write(edited_contents)
  end
end
