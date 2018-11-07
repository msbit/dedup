#!/usr/bin/env ruby

require 'digest'
require 'json'

all = {}

ARGV.map { |p| File.absolute_path(p) }.each do |base_path|
  Dir.glob("#{base_path}/**/*").select { |p| File.file?(p) }.each do |file|
    digest = Digest::SHA1.file(file).to_s
    all[digest] = [] unless all.key?(digest)
    all[digest] << file
  end
end

duplicate = all.select { |_k, v| v.size > 1 }
unique = all.select { |_k, v| v.size == 1 }

File.open('dedup.all.json', 'w') { |f| f.write(JSON.pretty_generate(all)) }
File.open('dedup.duplicate.json', 'w') { |f| f.write(JSON.pretty_generate(duplicate)) }
File.open('dedup.unique.json', 'w') { |f| f.write(JSON.pretty_generate(unique)) }
