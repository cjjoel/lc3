# frozen_string_literal: true

module LC3
  class VM
    @@jump_table[ST] = proc do |instruction|
      source_register = instruction[9..11]
      pc_offset = sign_extend(instruction[0..8], 8)
      address = (registers[PC] + pc_offset)[0..15]
      memory[address] = registers[source_register]
    end

    @@jump_table[STI] = proc do |instruction|
      source_register = instruction[9..11]
      pc_offset = sign_extend(instruction[0..8], 8)
      address = (registers[PC] + pc_offset)[0..15]
      memory[memory[address]] = registers[source_register]
    end

    @@jump_table[STR] = proc do |instruction|
      source_register = instruction[9..11]
      base_register = instruction[6..8]
      pc_offset = sign_extend(instruction[0..5], 5)
      address = (registers[base_register] + pc_offset)[0..15]
      memory[address] = registers[source_register]
    end
  end
end
