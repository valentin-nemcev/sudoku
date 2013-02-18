#!/usr/bin/env ruby

ARGF.read.split("\n\n").slice(1..-2).select.with_index do |p, i|
  i % 3 == 0
end.each do |chunk|
  puts chunk.gsub(/[^\d]/, '')
end

