# frozen_string_literal: true

require 'test_helper'

class TypeTest < Minitest::Test
  def test_comment
    line = '# foobar'
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:comment, result)
  end

  def test_comment_with_spaces
    line = '  # foobar  '
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:comment, result)
  end

  def test_comment_with_tabs
    line = '	# foobar	'
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:comment, result)
  end

  def test_comment_with_spaces_and_tabs
    line = '  	# foobar	  '
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:comment, result)
  end

  def test_action
    line = 'def foo'
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:action, result)
  end

  def test_action_with_spaces
    line = '  def bar  '
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:action, result)
  end

  def test_action_with_tabs
    line = '	def foo	'
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:action, result)
  end

  def test_action_with_comment
    line = 'def bar # comment'
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:action, result)
  end

  def test_non_action_method
    line = 'def carrot'
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:code, result)
  end

  def test_code
    line = 'puts "hello world!"'
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:code, result)
  end

  def test_code_with_comment
    line = 'puts "hello world!" # hey'
    result = Chusaku::Type.call(line: line, actions: %w[foo bar])
    assert_equal(:code, result)
  end
end
