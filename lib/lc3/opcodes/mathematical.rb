# frozen_string_literal: true

module LC3
  class VM
    @@jump_table[ADD] = proc do |instruction|
      process_arithmetic_instruction(instruction, :+)
    end

    @@jump_table[AND] = proc do |instruction|
      process_arithmetic_instruction(instruction, :&)
    end

    @@jump_table[NOT] = proc do |instruction|
      destination_register = instruction[9..11]
      source_register = instruction[6..8]
      registers[destination_register] = registers[source_register] ^ 0xFFFF
      registers[COND] = extract_sign(registers[destination_register])
    end

    private

    def process_arithmetic_instruction(instruction, operator)
      destination_register = instruction[9..11]
      source_register1 = instruction[6..8]

      registers[destination_register] = registers[source_register1]
                                        .method(operator)
                                        .call(second_number(instruction))[0..15]
      registers[COND] = extract_sign(registers[destination_register])
    end

    def second_number(instruction)
      is_immediate_mode = instruction[5] == 1
      is_immediate_mode ? sign_extend(instruction[0..4], 4) : registers[instruction[0..2]]
    end
  end
end
