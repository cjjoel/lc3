# frozen_string_literal: true

module LC3
  DEFAULT_PC_ADDRESS = 0x3000
  POSISTIVE_FLAG = 1 << 0
  ZERO_FLAG = 1 << 1
  NEGATIVE_FLAG = 1 << 2

  module REGISTERS
    R0 = 0
    R1 = 1
    R2 = 2
    R3 = 3
    R4 = 4
    R5 = 5
    R6 = 6
    R7 = 7
    PC = 8
    COND = 9
    COUNT = 10
  end

  module OPCODES
    BR = 0
    ADD = 1
    AND = 5
    LDI = 10
    JMP = 12
  end
end
