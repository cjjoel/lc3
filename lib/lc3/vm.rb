# frozen_string_literal: true

require "io/console"
require_relative "constants"

module LC3
  class VM
    include REGISTERS
    include OPCODES
    include TRAPCODES

    attr_accessor :memory, :registers, :running

    def initialize
      @memory = []
      @registers = Array.new(10, 0)
      @running = true
    end

    def load_bytecode(bytecode, origin = DEFAULT_PC_ADDRESS)
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
        case opcode
        when ADD
          process_arithmetic_instruction(instruction, :+)
        when LDI
          destination_register = instruction[9..11]
          pc_offset = sign_extend(instruction[0..8], 8)
          address = (registers[PC] + pc_offset)[0..15]
          registers[destination_register] = memory[memory[address]]
          update_flags(registers[destination_register])
        when AND
          process_arithmetic_instruction(instruction, :&)
        when BR
          condition = registers[COND].anybits?(instruction[9..11])
          pc_offset = sign_extend(instruction[0..8], 8)
          address = (registers[PC] + pc_offset)[0..15]
          registers[PC] = address if condition
        when JMP
          address = registers[instruction[6..8]]
          registers[PC] = address
        when JSR
          registers[R7] = registers[PC]
          if (instruction[11]).zero?
            base_register = registers[instruction[6..8]]
            registers[PC] = base_register
          else
            pc_offset = sign_extend(instruction[0..10], 10)
            registers[PC] = (registers[PC] + pc_offset)[0..15]
          end
        when LD
          destination_register = instruction[9..11]
          pc_offset = sign_extend(instruction[0..8], 8)
          address = (registers[PC] + pc_offset)[0..15]
          registers[destination_register] = memory[address]
          update_flags(registers[destination_register])
        when LDR
          destination_register = instruction[9..11]
          base_register = registers[instruction[6..8]]
          pc_offset = sign_extend(instruction[0..5], 5)
          address = (base_register + pc_offset)[0..15]
          registers[destination_register] = memory[address]
          update_flags(registers[destination_register])
        when LEA
          destination_register = instruction[9..11]
          pc_offset = sign_extend(instruction[0..8], 8)
          registers[destination_register] = (registers[PC] + pc_offset)[0..15]
          update_flags(registers[destination_register])
        when NOT
          destination_register = instruction[9..11]
          source_register = instruction[6..8]
          registers[destination_register] = registers[source_register] ^ 0xFFFF
          update_flags(registers[destination_register])
        when ST
          source_register = instruction[9..11]
          pc_offset = sign_extend(instruction[0..8], 8)
          address = (registers[PC] + pc_offset)[0..15]
          memory[address] = registers[source_register]
        when STI
          source_register = instruction[9..11]
          pc_offset = sign_extend(instruction[0..8], 8)
          address = (registers[PC] + pc_offset)[0..15]
          memory[memory[address]] = registers[source_register]
        when STR
          source_register = instruction[9..11]
          base_register = instruction[6..8]
          pc_offset = sign_extend(instruction[0..5], 5)
          address = (registers[base_register] + pc_offset)[0..15]
          memory[address] = registers[source_register]
        when TRAP
          process_trap_instruction(instruction)
        else
          puts "Unknown opcode #{opcode.to_s(16)}"
        end
      end
      self
    end

    private

    def process_arithmetic_instruction(instruction, operator)
      destination_register = instruction[9..11]
      source_register1 = instruction[6..8]
      is_immediate_mode = instruction[5] == 1
      if is_immediate_mode
        number = sign_extend(instruction[0..4], 4)
        registers[destination_register] = registers[source_register1].method(operator).call(number)[0..15]
      else
        source_register2 = instruction[0..2]
        registers[destination_register] =
          registers[source_register1].method(operator).call(registers[source_register2])[0..15]
      end
      update_flags(registers[destination_register])
    end

    def process_trap_instruction(instruction)
      registers[R7] = registers[PC]
      trap_routine = instruction[0..7]
      case trap_routine
      when GETC
        character = $stdin.getch
        registers[R0] = character.sub("\r", "\n").ord
        update_flags(registers[R0])
      when OUT
        character = registers[R0]
        $stdout.putc(character)
      when PUTS
        string = memory[registers[R0]..]
                 .take_while { |code| !code.zero? }
                 .reduce("") { |acc, code| acc + code.chr }
        print string
      when IN
        print "Enter a character: "
        character = $stdin.getch
        $stdout.putc(character)
        registers[R0] = character.ord
        update_flags(registers[R0])
      when PUTSP
        character_codes = memory[registers[R0]..].take_while { |code| !code.zero? }
        string = character_codes.reduce("") do |acc, code|
          character1 = code[0..7].chr
          character2 = code[8..15].chr
          characters = character2 == "\x00" ? character1 : character1 + character2
          acc + characters
        end
        print string
      when HALT
        @running = false
      end
    end

    def sign_extend(number, sign_bit = 4)
      number[sign_bit] == 1 ? (number | (0xFFFF << sign_bit))[0..15] : number
    end

    def update_flags(register_value)
      registers[COND] = if register_value.zero?
                          ZERO_FLAG
                        elsif register_value[15] == 1
                          NEGATIVE_FLAG
                        else
                          POSISTIVE_FLAG
                        end
    end
  end
end
