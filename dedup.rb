#!/usr/bin/env ruby

require 'digest'
require 'json'

hashes = {}

ARGV.map { |p| File.absolute_path(p) }.each do |base_path|
  Dir.glob("#{base_path}/**/*").select { |p| File.file?(p) }.each do |file|
    digest = Digest::SHA1.file(file).to_s
    hashes[digest] = [] unless hashes.key?(digest)
    hashes[digest] << file
  end
end

pp hashes
