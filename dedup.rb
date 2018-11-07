#!/usr/bin/env ruby

require 'digest'
require 'json'

hashes = {}

Dir.glob('**/*').select { |path| File.file?(path) }.each do |file|
  digest = Digest::SHA512.file file
  hashes[digest] = [] unless hashes.key? digest
  hashes[digest] << file
end

pp hashes
