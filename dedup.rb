#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler'

Dir.chdir(__dir__) { Bundler.require(:default) }

require 'digest'
require 'find'

IGNORED_DIGESTS = ['da39a3ee5e6b4b0d3255bfef95601890afd80709'].freeze

def get_files(paths)
  files = {}

  puts 'Generating file list...'
  progress_bar = ProgressBar.create(format: '%t: |%B| %a /%E', total: nil)

  Find.find(*paths) do |f|
    begin
      files[f] = File.stat(f) if File.file?(f)
    rescue SystemCallError => e
      puts e
    end
    progress_bar.increment
  end
  progress_bar.finish

  files
end

def hash_files(files)
  hashes = {}

  total = files.reduce(0) do |memo, entry|
    _, stat = entry
    memo + stat.size
  end

  puts 'Hashing files...'
  progress_bar = ProgressBar.create(format: '%t: |%B| %a /%E', total: total)

  files.each do |entry|
    file, stat = entry
    begin
      digest = Digest::SHA1.file(file).to_s
      unless IGNORED_DIGESTS.include?(digest)
        hashes[digest] = [] unless hashes.key?(digest)
        hashes[digest] << file
      end
    rescue SystemCallError => e
      puts e
    end
    progress_bar.progress += stat.size
  end

  hashes
end

def get_saveable_size(hashes)
  hashes.reduce(0) do |memo, value|
    _, files = value
    memo + ((files.size - 1) * File.size(files.first))
  end
end

execution_time = Time.now.to_i

ARGV << '.' if ARGV.empty?

files = get_files(ARGV)
hashes = hash_files(files)

duplicate_hashes = hashes.select { |_k, v| v.size > 1 }
unique_hashes = hashes.select { |_k, v| v.size == 1 }

saveable_size = get_saveable_size(duplicate_hashes)

puts "Could save #{saveable_size} bytes"

File.open("dedup.#{execution_time}.all.json", 'w') do |f|
  f.write(JSON.pretty_generate(hashes))
end
File.open("dedup.#{execution_time}.duplicate.json", 'w') do |f|
  f.write(JSON.pretty_generate(duplicate_hashes))
end
File.open("dedup.#{execution_time}.unique.json", 'w') do |f|
  f.write(JSON.pretty_generate(unique_hashes))
end
