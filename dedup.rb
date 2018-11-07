#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'ruby-progressbar'

IGNORED_DIGESTS = ['da39a3ee5e6b4b0d3255bfef95601890afd80709'].freeze

def get_all_files(base_paths)
  puts 'Generating file list...'
  progress_bar = ProgressBar.create(total: base_paths.size)

  base_paths.map { |p| File.absolute_path(p) }.map do |base_path|
    files = Dir.glob("#{base_path}/**/{*,.*}").select { |p| File.file?(p) }
    progress_bar.increment
    files
  end.flatten.uniq.sort do |x, y|
    File.size(y) <=> File.size(x)
  end
end

def hash_all_files(files)
  hashes = {}

  total = files.reduce(0) do |memo, file|
    memo + File.size(file)
  end

  puts 'Hashing files...'
  progress_bar = ProgressBar.create(total: total)

  files.each_with_index do |file, _i|
    digest = Digest::SHA1.file(file).to_s
    unless IGNORED_DIGESTS.include?(digest)
      hashes[digest] = [] unless hashes.key?(digest)
      hashes[digest] << file
    end
    progress_bar.progress += File.size(file)
  end

  hashes
end

execution_time = Time.now.to_i

ARGV << '.' if ARGV.empty?

files = get_all_files(ARGV)
all_hashes = hash_all_files(files)

duplicate_hashes = all_hashes.select { |_k, v| v.size > 1 }
unique_hashes = all_hashes.select { |_k, v| v.size == 1 }

saveable_size = duplicate_hashes.reduce(0) do |memo, value|
  _digest, files = value
  memo + ((files.size - 1) * File.size(files.first))
end

puts "Could save #{saveable_size} bytes"

File.open("dedup.#{execution_time}.all.json", 'w') { |f| f.write(JSON.pretty_generate(all_hashes)) }
File.open("dedup.#{execution_time}.duplicate.json", 'w') { |f| f.write(JSON.pretty_generate(duplicate_hashes)) }
File.open("dedup.#{execution_time}.unique.json", 'w') { |f| f.write(JSON.pretty_generate(unique_hashes)) }
