#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'ruby-progressbar'

all = {}

ARGV << '.' if ARGV.empty?

files = ARGV.map { |p| File.absolute_path(p) }.map do |base_path|
  Dir.glob("#{base_path}/**/*").select { |p| File.file?(p) }
end
files.flatten!

progress_bar = ProgressBar.create
progress_bar.total = files.size

files.each_with_index do |file, _i|
  digest = Digest::SHA1.file(file).to_s
  all[digest] = [] unless all.key?(digest)
  all[digest] << file
  progress_bar.increment
end

duplicate = all.select { |_k, v| v.size > 1 }
unique = all.select { |_k, v| v.size == 1 }

File.open('dedup.all.json', 'w') { |f| f.write(JSON.pretty_generate(all)) }
File.open('dedup.duplicate.json', 'w') { |f| f.write(JSON.pretty_generate(duplicate)) }
File.open('dedup.unique.json', 'w') { |f| f.write(JSON.pretty_generate(unique)) }
