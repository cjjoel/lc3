# frozen_string_literal: true

require_relative "lc3/version"
require_relative "lc3/vm"

Dir[File.join("./lib/lc3/opcodes/*.rb")].sort.each do |file|
  require file
end
