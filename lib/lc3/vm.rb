# frozen_string_literal: true

require_relative "constants"

module LC3
  class VM
    include REGISTERS

    attr_accessor :memory, :registers, :running

    def initialize
      @memory = []
      @registers = Array.new(10, 0)
      @running = true
    end

    def load_bytecode(bytecode)
      memory.insert(DEFAULT_PC_ADDRESS, *bytecode)
      registers[PC] = DEFAULT_PC_ADDRESS
      self
    end

    def execute
      while running
        @running = false
      end
      registers[PC] += 1
    end
  end
end
