# frozen_string_literal: true

module LC3
  module Constants
    REGISTER_COUNT = 10
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
      LD = 2
      ST = 3
      JSR = 4
      AND = 5
      LDR = 6
      STR = 7
      NOT = 9
      LDI = 10
      STI = 11
      JMP = 12
      LEA = 14
      TRAP = 15
    end

    module TRAPCODES
      GETC = 0x20
      OUT = 0x21
      PUTS = 0x22
      IN = 0x23
      PUTSP = 0x24
      HALT = 0x25
    end
  end
end
