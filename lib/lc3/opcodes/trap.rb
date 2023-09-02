# frozen_string_literal: true

module LC3
  class VM
    @@jump_table[TRAP] = proc do |instruction|
      registers[R7] = registers[PC]
      trap_routine = instruction[0..7]
      case trap_routine
      when GETC
        character = $stdin.getch
        registers[R0] = character.sub("\r", "\n").ord
        registers[COND] = extract_sign(registers[R0])
      when OUT
        character = registers[R0]
        $stdout.putc(character)
      when PUTS
        string = memory[registers[R0]..]
                 .take_while { |code| !code.zero? }
                 .reduce("") { |acc, code| acc + code.chr }
        print string
      when IN
        process_in_instriction
      when PUTSP
        process_putsp_instruction
      when HALT
        @running = false
      end
    end

    private

    def process_in_instriction
      print "Enter a character: "
      character = $stdin.getch
      $stdout.putc(character)
      registers[R0] = character.ord
      registers[COND] = extract_sign(registers[R0])
    end

    def process_putsp_instruction
      character_codes = memory[registers[R0]..].take_while { |code| !code.zero? }
      string = character_codes.reduce("") do |acc, code|
        character1 = code[0..7].chr
        character2 = code[8..15].chr
        characters = character2 == "\x00" ? character1 : character1 + character2
        acc + characters
      end
      print string
    end
  end
end
