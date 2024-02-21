# frozen_string_literal: true

module LC3
  class VM
    JUMP_TABLE[LDI] = proc do |instruction|
      destination_register = instruction[9..11]
      pc_offset = sign_extend(instruction[0..8], 8)
      address = (registers[PC] + pc_offset)[0..15]
      registers[destination_register] = memory[memory[address]]
      registers[COND] = extract_sign(registers[destination_register])
    end

    JUMP_TABLE[LD] = proc do |instruction|
      destination_register = instruction[9..11]
      pc_offset = sign_extend(instruction[0..8], 8)
      address = (registers[PC] + pc_offset)[0..15]
      registers[destination_register] = memory[address]
      registers[COND] = extract_sign(registers[destination_register])
    end

    JUMP_TABLE[LDR] = proc do |instruction|
      destination_register = instruction[9..11]
      base_register = registers[instruction[6..8]]
      pc_offset = sign_extend(instruction[0..5], 5)
      address = (base_register + pc_offset)[0..15]
      registers[destination_register] = memory[address]
      registers[COND] = extract_sign(registers[destination_register])
    end

    JUMP_TABLE[LEA] = proc do |instruction|
      destination_register = instruction[9..11]
      pc_offset = sign_extend(instruction[0..8], 8)
      registers[destination_register] = (registers[PC] + pc_offset)[0..15]
      registers[COND] = extract_sign(registers[destination_register])
    end
  end
end
