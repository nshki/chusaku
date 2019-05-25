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
    assert_equal \
      [nil, nil, nil, 'foo', nil],
      (result.map { |r| r[:action] })
  end

  def test_empty_file
    result = Chusaku::Parser.call \
      path: "#{__dir__}/examples/empty.rb",
      actions: []
    assert_equal([{}], result)
  end

  def test_comment
    line = '# foobar'
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal({ type: :comment, body: '# foobar', action: nil }, result)
  end

  def test_comment_with_spaces
    line = '  # foobar  '
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal({ type: :comment, body: '  # foobar  ', action: nil }, result)
  end

  def test_comment_with_tabs
    line = '	# foobar	'
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal({ type: :comment, body: '	# foobar	', action: nil }, result)
  end

  def test_comment_with_spaces_and_tabs
    line = '  	# foobar	  '
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal \
      ({ type: :comment, body: '  	# foobar	  ', action: nil }),
      result
  end

  def test_action
    line = 'def foo'
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal({ type: :action, body: 'def foo', action: 'foo' }, result)
  end

  def test_action_with_spaces
    line = '  def bar  '
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal({ type: :action, body: '  def bar  ', action: 'bar' }, result)
  end

  def test_action_with_tabs
    line = '	def foo	'
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal({ type: :action, body: '	def foo	', action: 'foo' }, result)
  end

  def test_action_with_comment
    line = 'def bar # comment'
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal \
      ({ type: :action, body: 'def bar # comment', action: 'bar' }),
      result
  end

  def test_non_action_method
    line = 'def carrot'
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal({ type: :code, body: 'def carrot', action: nil }, result)
  end

  def test_code
    line = 'puts "hello world!"'
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal \
      ({ type: :code, body: 'puts "hello world!"', action: nil }),
      result
  end

  def test_code_with_comment
    line = 'puts "hello world!" # hey'
    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])
    assert_equal \
      ({ type: :code, body: 'puts "hello world!" # hey', action: nil }),
      result
  end
end
