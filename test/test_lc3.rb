# frozen_string_literal: true

require "test_helper"

class TestLC3 < Minitest::Test
  include LC3::REGISTERS

  def test_that_it_has_a_version_number
    refute_nil ::LC3::VERSION
  end

  def test_registers_should_be_set
    bytecode = [0x1621, 0x0000]
    registers = LC3::VM.new.load_bytecode(bytecode).registers
    expected_register_values = Array.new(10, 0)
    expected_register_values[PC] = LC3::DEFAULT_PC_ADDRESS

    assert_equal expected_register_values, registers
  end

  def test_should_load_bytecode_to_memory
    bytecode = [0x1621, 0x0000]
    memory = LC3::VM.new.load_bytecode(bytecode).memory

    assert_equal bytecode, memory[LC3::DEFAULT_PC_ADDRESS..]
  end

  def test_should_add_register_and_number
    # ADD R3, R0, 1
    bytecode = [0x1621, 0x0000]
    registers = LC3::VM.new.load_bytecode(bytecode).execute.registers

    assert_equal 1, registers[R3]
  end

  def test_should_add_registers
    # ADD R3, R0, R1
    bytecode = [0x1601, 0x0000]
    vm = LC3::VM.new
    vm.registers[R0] = vm.registers[R1] = 1
    vm.load_bytecode(bytecode).execute

    assert_equal 2, vm.registers[R3]
  end

  def test_should_indirectly_load_value_to_register
    # LDI R0, 3
    bytecode = [0xA003, 0, 0, 0, 0x3006, 0, 0xFFFF]
    registers = LC3::VM.new.load_bytecode(bytecode).execute.registers

    assert_equal 0xFFFF, registers[R0]
  end

  def test_should_perform_bitwise_and_on_register_and_number
    # AND R3, R0, 0x0F
    bytecode = [0x562F , 0x0000]
    vm = LC3::VM.new
    vm.registers[R0] = 0xFFFF
    vm.load_bytecode(bytecode).execute
    assert_equal 0xF, vm.registers[R3]
  end

  def test_should_perform_bitwise_and_on_registers
    # AND R3, R0, R1
    bytecode = [0x5601 , 0x0000]
    vm = LC3::VM.new
    vm.registers[R0] = 0xFFFF
    vm.registers[R1] = 0xF0F0
    vm.load_bytecode(bytecode).execute
    assert_equal 0xF0F0, vm.registers[R3]
  end
end
