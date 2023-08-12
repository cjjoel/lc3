# frozen_string_literal: true

require_relative "constants"

module LC3
  class VM
    include REGISTERS
    include OPCODES

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
        instruction = memory[registers[PC]]
        opcode = instruction[12..15]
        registers[PC] += 1
        case opcode
        when ADD
          destination_register = instruction[9..11]
          source_register1 = instruction[6..8]
          is_immediate_mode = instruction[5] == 1
          if is_immediate_mode
            number = sign_extend(instruction & 0x1F)
            registers[destination_register] = registers[source_register1] + number
          else
            source_register2 = instruction[0..2]
            registers[destination_register] = registers[source_register1] + registers[source_register2]
          end
          update_flags(registers[destination_register])
        else
          @running = false
        end
      end
      self
    end

    private

    def sign_extend(number, sign_bit = 4)
      number[sign_bit] == 1 ? number | (0xFFFF << sign_bit) : number
    end

    def update_flags(register_value)
      registers[COND] = if register_value.zero?
                          ZERO_FLAG
                        elsif register_value[16] == 1
                          NEGATIVE_FLAG
                        else
                          POSISTIVE_FLAG
                        end
    end
  end
end