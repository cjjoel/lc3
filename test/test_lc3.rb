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
end
