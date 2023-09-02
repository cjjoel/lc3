# frozen_string_literal: true

module LC3
  class VM
    @@jump_table[BR] = proc do |instruction|
      condition = registers[COND].anybits?(instruction[9..11])
      pc_offset = sign_extend(instruction[0..8], 8)
      address = (registers[PC] + pc_offset)[0..15]
      registers[PC] = address if condition
    end

    @@jump_table[JMP] = proc do |instruction|
      address = registers[instruction[6..8]]
      registers[PC] = address
    end

    @@jump_table[JSR] = proc do |instruction|
      registers[R7] = registers[PC]
      if (instruction[11]).zero?
        base_register = registers[instruction[6..8]]
        registers[PC] = base_register
      else
        pc_offset = sign_extend(instruction[0..10], 10)
        registers[PC] = (registers[PC] + pc_offset)[0..15]
      end
    end
  end
end
