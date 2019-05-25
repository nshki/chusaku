# frozen_string_literal: true

require 'test_helper'

class TypeTest < Minitest::Test
  def test_comment
    line = '# foobar'
    result = Chusaku::Type.call(line)
    assert_equal(:comment, result)
  end

  def test_comment_with_spaces
    line = '  # foobar  '
    result = Chusaku::Type.call(line)
    assert_equal(:comment, result)
  end

  def test_comment_with_tabs
    line = '	# foobar	'
    result = Chusaku::Type.call(line)
    assert_equal(:comment, result)
  end

  def test_comment_with_spaces_and_tabs
    line = '  	# foobar	  '
    result = Chusaku::Type.call(line)
    assert_equal(:comment, result)
  end

  def test_method
    line = 'def method'
    result = Chusaku::Type.call(line)
    assert_equal(:def, result)
  end

  def test_method_with_spaces
    line = '  def method  '
    result = Chusaku::Type.call(line)
    assert_equal(:def, result)
  end

  def test_method_with_tabs
    line = '	def method	'
    result = Chusaku::Type.call(line)
    assert_equal(:def, result)
  end

  def test_method_with_comment
    line = 'def method # comment'
    result = Chusaku::Type.call(line)
    assert_equal(:def, result)
  end

  def test_code
    line = 'puts "hello world!"'
    result = Chusaku::Type.call(line)
    assert_equal(:code, result)
  end

  def test_code_with_comment
    line = 'puts "hello world!" # hey'
    result = Chusaku::Type.call(line)
    assert_equal(:code, result)
  end
end
