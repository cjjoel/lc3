# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "lc3"

require "minitest/autorun"

def simulate_stdin(*inputs)
  io = StringIO.new
  inputs.flatten.each { |str| io.puts(str) }
  io.rewind

  actual_stdin = $stdin
  $stdin = io
  yield
ensure
  $stdin = actual_stdin
end
