#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'ruby-progressbar'

def get_all_files(base_paths)
  puts 'Generating file list...'
  progress_bar = ProgressBar.create(total: base_paths.size)

  all_files = base_paths.map { |p| File.absolute_path(p) }.map do |base_path|
    files = Dir.glob("#{base_path}/**/{*,.*}").select { |p| File.file?(p) }
    progress_bar.increment
    files
  end
  all_files.flatten!
end

def hash_all_files(files)
  hashes = {}

  puts 'Hashing files...'
  progress_bar = ProgressBar.create(total: files.size)

  files.each_with_index do |file, _i|
    digest = Digest::SHA1.file(file).to_s
    hashes[digest] = [] unless hashes.key?(digest)
    hashes[digest] << file
    progress_bar.increment
  end

  hashes
end

ARGV << '.' if ARGV.empty?

files = get_all_files(ARGV)
all_hashes = hash_all_files(files)

duplicate_hashes = all_hashes.select { |_k, v| v.size > 1 }
unique_hashes = all_hashes.select { |_k, v| v.size == 1 }

File.open('dedup.all.json', 'w') { |f| f.write(JSON.pretty_generate(all_hashes)) }
File.open('dedup.duplicate.json', 'w') { |f| f.write(JSON.pretty_generate(duplicate_hashes)) }
File.open('dedup.unique.json', 'w') { |f| f.write(JSON.pretty_generate(unique_hashes)) }
