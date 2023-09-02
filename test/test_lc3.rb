# frozen_string_literal: true

require "test_helper"

class TestLC3 < Minitest::Test
  include LC3::Constants
  include REGISTERS

  def test_that_it_has_a_version_number
    refute_nil ::LC3::VERSION
  end

  def test_registers_should_be_set
    bytecode = [0x1621, 0xF025]
    registers = LC3::VM.new.load_bytecode(bytecode).registers
    expected_register_values = Array.new(10, 0)
    expected_register_values[PC] = DEFAULT_PC_ADDRESS

    assert_equal expected_register_values, registers
  end

  def test_should_load_bytecode_to_memory
    bytecode = [0x1621, 0xF025]
    memory = LC3::VM.new.load_bytecode(bytecode).memory

    assert_equal bytecode, memory[DEFAULT_PC_ADDRESS..]
  end

  def test_should_load_image_file_into_memory
    file = Tempfile.new(["program", ".obj"], binmode: true)
    contents = [0x3000, 0x1621, 0xF025]
    file.write(contents.pack("S>*"))
    file.close
    memory = LC3::VM.new.load_image_file(file.path).memory

    assert_equal contents[1..], memory[DEFAULT_PC_ADDRESS..]
  end

  def test_should_add_register_and_number
    # ADD R3, R0, 1
    # TRAP 0x25
    bytecode = [0x1621, 0xF025]
    registers = LC3::VM.new.load_bytecode(bytecode).execute.registers

    assert_equal 1, registers[R3]
  end

  def test_should_add_registers
    # ADD R3, R0, R1
    # TRAP 0x25
    bytecode = [0x1601, 0xF025]
    vm = LC3::VM.new
    vm.registers[R0] = vm.registers[R1] = 1
    vm.load_bytecode(bytecode).execute

    assert_equal 2, vm.registers[R3]
  end

  def test_should_indirectly_load_value_to_register
    # LDI R0, 3
    # TRAP 0x25
    # TRAP 0x25
    # TRAP 0x25
    # 0x3006
    # TRAP 0x25
    # 0x1111
    bytecode = [0xA003, 0xF025, 0xF025, 0xF025, 0x3006, 0xF025, 0x1111]
    registers = LC3::VM.new.load_bytecode(bytecode).execute.registers

    assert_equal 0x1111, registers[R0]
  end

  def test_should_perform_bitwise_and_on_register_and_number
    # AND R3, R0, 0x0F
    # TRAP 0x25
    bytecode = [0x562F, 0xF025]
    vm = LC3::VM.new
    vm.registers[R0] = 0xFFFF
    vm.load_bytecode(bytecode).execute

    assert_equal 0xF, vm.registers[R3]
  end

  def test_should_perform_bitwise_and_on_registers
    # AND R3, R0, R1
    # TRAP 0x25
    bytecode = [0x5601, 0xF025]
    vm = LC3::VM.new
    vm.registers[R0] = 0xFFFF
    vm.registers[R1] = 0xF0F0
    vm.load_bytecode(bytecode).execute

    assert_equal 0xF0F0, vm.registers[R3]
  end

  def test_should_branch_on_negative_value
    # BRn 2
    # ADD R0, R0, 1
    # TRAP 0x25
    # TRAP 0x25
    bytecode = [0x0802, 0x1021, 0xF025, 0xF025]
    vm = LC3::VM.new
    vm.registers[COND] = 0b100
    vm.load_bytecode(bytecode).execute

    refute_equal 1, vm.registers[R0]
  end

  def test_should_branch_on_zero_value
    # BRz 2
    # ADD R0, R0, 1
    # TRAP 0x25
    # TRAP 0x25
    bytecode = [0x0402, 0x1021, 0xF025, 0xF025]
    vm = LC3::VM.new
    vm.registers[COND] = 0b010
    vm.load_bytecode(bytecode).execute

    refute_equal 1, vm.registers[R0]
  end

  def test_should_branch_on_positive_value
    # BRp 2
    # ADD R0, R0, 1
    # TRAP 0x25
    # TRAP 0x25
    bytecode = [0x0202, 0x1021, 0xF025, 0xF025]
    vm = LC3::VM.new
    vm.registers[COND] = 0b001
    vm.load_bytecode(bytecode).execute

    refute_equal 1, vm.registers[R0]
  end

  def test_should_jump_to_address
    # JMP 7
    # ADD R0, R0, 1
    # TRAP 0x25
    # TRAP 0x25
    bytecode = [0xC1C0, 0x1021, 0xF025, 0xF025]
    vm = LC3::VM.new
    vm.registers[R7] = 0x3003
    vm.load_bytecode(bytecode).execute

    refute_equal 1, vm.registers[R0]
  end

  def test_should_jump_to_subroutine_address_stored_in_register
    # JSR 1
    # ADD R0, R0, 1
    # HALT
    # ST R7, 0
    # TRAP 0x25
    # TRAP 0x25
    bytecode = [0x4040, 0x1021, 0xF025, 0x3E00, 0xF025, 0xF025]
    vm = LC3::VM.new
    vm.registers[R1] = 0x3003
    vm.load_bytecode(bytecode).execute

    assert_equal 0x3001, vm.memory[0x3004]
    refute_equal 1, vm.registers[R0]
  end

  def test_should_jump_to_subroutine_address_stored_in_memory
    # JSR 2
    # ADD R0, R0, 1
    # TRAP 0x25
    # ST R7, 0
    # TRAP 0x25
    # TRAP 0x25
    bytecode = [0x4802, 0x1021, 0xF025, 0x3E00, 0xF025, 0xF025]
    vm = LC3::VM.new.load_bytecode(bytecode).execute

    assert_equal 0x3001, vm.memory[0x3004]
    refute_equal 1, vm.registers[R0]
  end

  def test_should_load_value_from_memory_with_offset
    # LD RO, 2
    # TRAP 0x25
    # TRAP 0x25
    # 0xFFF9
    bytecode = [0x2002, 0xF025, 0xF025, 0xFFF9]
    registers = LC3::VM.new.load_bytecode(bytecode).execute.registers

    assert_equal 0xFFF9, registers[R0]
    assert_equal NEGATIVE_FLAG, registers[COND]
  end

  def test_should_load_value_from_memory_with_offset_and_register
    # LDR R0, R1, 1
    # TRAP 0x25
    # TRAP 0x25
    # 0x0000
    bytecode = [0x6041, 0xF025, 0xF025, 0x0000]
    vm = LC3::VM.new
    vm.registers[R1] = 0x3002
    vm.load_bytecode(bytecode).execute

    assert_equal 0x0000, vm.registers[R0]
    assert_equal ZERO_FLAG, vm.registers[COND]
  end

  def test_should_load_address_into_register
    # LEA R0, 2
    # TRAP 0x25
    # TRAP 0x25
    # 0x1111
    bytecode = [0xE002, 0xF025, 0xF025, 0x1111]
    registers = LC3::VM.new.load_bytecode(bytecode).execute.registers

    assert_equal 0x3003, registers[R0]
    assert_equal POSISTIVE_FLAG, registers[COND]
  end

  def test_should_perform_bitwise_not_on_register
    # NOT R0, R0
    # TRAP 0x25
    bytecode = [0x903F, 0xF025]
    vm = LC3::VM.new
    vm.registers[R0] = 0x0002
    vm.load_bytecode(bytecode).execute

    assert_equal 0xFFFD, vm.registers[R0]
    assert_equal NEGATIVE_FLAG, vm.registers[COND]
  end

  def test_should_store_value_to_memory
    # ST R0, 2
    # TRAP 0x25
    bytecode = [0x3002, 0xF025]
    vm = LC3::VM.new
    vm.registers[R0] = 0x1111
    vm.load_bytecode(bytecode).execute

    assert_equal vm.registers[R0], vm.memory[0x3003]
  end

  def test_should_indirectly_store_value_to_memory
    # STI R0, 2
    # TRAP 0x25
    # 0x3004
    bytecode = [0xB001, 0xF025, 0x3004]
    vm = LC3::VM.new
    vm.registers[R0] = 0x1111
    vm.load_bytecode(bytecode).execute

    assert_equal vm.registers[R0], vm.memory[0x3004]
  end

  def test_should_load_source_register_to_memory_at_combined_value_of_base_register_and_offset
    # STR R4, R2, #1
    # TRAP 0x25
    bytecode = [0x7881, 0xF025]
    vm = LC3::VM.new
    vm.registers[R2] = 0x3001
    vm.registers[R4] = 0x1111
    vm.load_bytecode(bytecode).execute

    assert_equal vm.registers[R4], vm.memory[0x3002]
  end

  def test_should_halt_the_virtual_machine
    # TRAP 0x25
    # ADD R0, R0, 1
    bytecode = [0xF025, 0x1021]
    registers = LC3::VM.new.load_bytecode(bytecode).execute.registers

    refute_equal 1, registers[R0]
    assert_equal 0x3001, registers[PC]
    assert_equal 0x3001, registers[R7]
  end

  def test_should_print_null_terminated_string
    # TRAP 0x22
    # HALT
    bytecode = [0xF022, 0xF025, 0x0048, 0x0065, 0x006C, 0x006C, 0x006F, 0x000A, 0x0000]
    vm = LC3::VM.new.load_bytecode(bytecode)
    vm.registers[R0] = 0x3002

    assert_output "Hello\n" do
      vm.execute
    end
    assert_equal 0x3002, vm.registers[PC]
    assert_equal 0x3002, vm.registers[R7]
  end

  def test_should_read_single_character
    # TRAP 0x20
    # TRAP 0x25
    bytecode = [0xF020, 0xF025]
    vm = LC3::VM.new.load_bytecode(bytecode)
    simulate_stdin("a") do
      vm.execute
    end

    assert_equal 97, vm.registers[R0]
    assert_equal 0x3002, vm.registers[PC]
    assert_equal 0x3002, vm.registers[R7]
  end

  def test_should_print_single_character
    # TRAP 0x21
    # TRAP 0x25
    bytecode = [0xF021, 0xF025]
    vm = LC3::VM.new.load_bytecode(bytecode)
    vm.registers[R0] = 0x0061

    assert_output "a" do
      vm.execute
    end
    assert_equal 0x3002, vm.registers[PC]
    assert_equal 0x3002, vm.registers[R7]
  end

  def test_should_prompt_read_and_echo_a_single_character
    # TRAP 0x23
    # TRAP 0x25
    bytecode = [0xF023, 0xF025]
    vm = LC3::VM.new.load_bytecode(bytecode)
    mock = MiniTest::Mock.new
    mock.expect :call, nil, ["Enter a character: "]

    vm.stub :print, mock do
      assert_output "a" do
        simulate_stdin("a") do
          vm.execute
        end
      end
    end

    assert_equal 97, vm.registers[R0]
    assert_equal 0x3002, vm.registers[PC]
    assert_equal 0x3002, vm.registers[R7]
    mock.verify
  end

  def test_should_print_null_terminated_byte_string
    # TRAP 0x24
    # TRAP 0x25
    bytecode = [0xF024, 0xF025, 0x6548, 0x6C6C, 0x006F, 0x000A, 0x0000]
    vm = LC3::VM.new.load_bytecode(bytecode)
    vm.registers[R0] = 0x3002

    assert_output "Hello\n" do
      vm.execute
    end
    assert_equal 0x3002, vm.registers[PC]
    assert_equal 0x3002, vm.registers[R7]
  end
end
