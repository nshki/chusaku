# frozen_string_literal: true

require 'test_helper'

class ParserTest < Minitest::Test
  def test_example_file
    result = Chusaku::Parser.call \
      path: "#{__dir__}/examples/example.rb",
      actions: %w[foo]
    assert_equal(5, result.size)
    assert_equal \
      %i[comment code comment action code],
      (result.map { |r| r[:type] })
    assert_equal \
      result.map { |r| r[:body] }.join,
      File.read("#{__dir__}/examples/example.rb")
  end

  def test_empty_file
    result = Chusaku::Parser.call \
      path: "#{__dir__}/examples/empty.rb",
      actions: []
    assert_equal([{}], result)
  end
end
