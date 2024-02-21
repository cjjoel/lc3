# frozen_string_literal: true

require "io/console"
require_relative "constants"

module LC3
  class VM
    include Constants::REGISTERS
    include Constants::OPCODES
    include Constants::TRAPCODES

    JUMP_TABLE = {}

    attr_accessor :memory, :registers, :running

    def initialize
      @memory = []
      @registers = Array.new(Constants::REGISTER_COUNT, 0)
      @running = true
    end

    def load_bytecode(bytecode, origin = Constants::DEFAULT_PC_ADDRESS)
      memory.insert(origin, *bytecode)
      registers[PC] = origin
      self
    end

    def load_image_file(path)
      bytecode = []
      File.open(path, "rb") do |file|
        while (instruction = file.read(2))
          bytecode.push(instruction.unpack1("H4").hex)
        end
      end
      origin = bytecode.shift
      load_bytecode(bytecode, origin)
    end

    def execute
      while running
        instruction = memory[registers[PC]]
        opcode = instruction[12..15]
        registers[PC] += 1
        if (opcode_method = JUMP_TABLE[opcode])
          instance_exec(instruction, &opcode_method)
        else
          puts "Unknown opcode #{opcode.to_s(16)}"
        end
      end
      self
    end

    private

    def sign_extend(number, sign_bit = 4)
      number[sign_bit] == 1 ? (number | (0xFFFF << sign_bit))[0..15] : number
    end

    def extract_sign(register_value)
      return Constants::ZERO_FLAG if register_value.zero?

      return Constants::NEGATIVE_FLAG if register_value[15] == 1

      Constants::POSISTIVE_FLAG
    end
  end
end
