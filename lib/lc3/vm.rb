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
          process_arithmetic_operation(instruction, :+)
        when LDI
          destination_register = instruction[9..11]
          pc_offset = sign_extend(instruction[0..8] & 0x1FF)
          registers[destination_register] = memory[memory[registers[PC] + pc_offset]]
          update_flags(registers[destination_register])
        when AND
          process_arithmetic_operation(instruction, :&)
        when BR
          condition = registers[COND].anybits?(instruction[9..11])
          pc_offset = sign_extend(instruction[0..8] & 0x1FF)
          registers[PC] += pc_offset if condition
        when JMP
          address = registers[instruction[6..8]]
          registers[PC] = address
        when JSR
          registers[R7] = registers[PC]
          if (instruction[11]).zero?
            base_register = registers[instruction[6..8]]
            registers[PC] = base_register
          else
            pc_offset = sign_extend(instruction[0..11] & 0x7FF)
            registers[PC] += pc_offset
          end
        else
          @running = false
        end
      end
      self
    end

    private

    def process_arithmetic_operation(instruction, operator)
      destination_register = instruction[9..11]
      source_register1 = instruction[6..8]
      is_immediate_mode = instruction[5] == 1
      if is_immediate_mode
        number = sign_extend(instruction & 0x1F)
        registers[destination_register] = registers[source_register1].method(operator).call(number)
      else
        source_register2 = instruction[0..2]
        registers[destination_register] =
          registers[source_register1].method(operator).call(registers[source_register2])
      end
      update_flags(registers[destination_register])
    end

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
