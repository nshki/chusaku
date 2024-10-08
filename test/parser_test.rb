require_relative "test_helper"

describe "Chusaku::Parser" do
  it "parses example file properly" do
    result = Chusaku::Parser.call \
      path: "#{__dir__}/mock/examples/example.rb",
      actions: %w[foo]

    assert_equal(4, result[:groups].size)
    assert_equal \
      %i[code comment action code],
      (result[:groups].map { |r| r[:type] })
    assert_equal \
      File.read("#{__dir__}/mock/examples/example.rb"),
      result[:groups].map { |r| r[:body] }.join
    assert_equal \
      [nil, nil, "foo", nil],
      (result[:groups].map { |r| r[:action] })
    assert_equal \
      [1, 2, 4, 5],
      (result[:groups].map { |r| r[:line_number] })
  end

  it "parses empty file properly" do
    expected = [{}]

    result = Chusaku::Parser.call \
      path: "#{__dir__}/mock/examples/empty.rb",
      actions: []

    assert_equal(expected, result[:groups])
  end

  it "parses comments properly" do
    expected = {type: :comment, body: "# foobar", action: nil}
    line = "# foobar"

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses comments with spaces properly" do
    expected = {type: :comment, body: "  # foobar  ", action: nil}
    line = "  # foobar  "

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses comments with tabs properly" do
    expected = {type: :comment, body: "\t# foobar\t", action: nil}
    line = "\t# foobar\t"

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses comments with spaces and tabs properly" do
    expected = {type: :comment, body: "  \t# foobar\t  ", action: nil}
    line = "  \t# foobar\t  "

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses controller actions properly" do
    expected = {type: :action, body: "def foo", action: "foo"}
    line = "def foo"

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses controller actions with spaces properly" do
    expected = {type: :action, body: "  def bar  ", action: "bar"}
    line = "  def bar  "

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses controller actions with tabs properly" do
    expected = {type: :action, body: "\tdef foo\t", action: "foo"}
    line = "\tdef foo\t"

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses controller actions with comments properly" do
    expected = {type: :action, body: "def bar # comment", action: "bar"}
    line = "def bar # comment"

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses regular methods properly" do
    expected = {type: :code, body: "def carrot", action: nil}
    line = "def carrot"

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses code blocks properly" do
    expected = {type: :code, body: 'puts "hello world!"', action: nil}
    line = 'puts "hello world!"'

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end

  it "parses code blocks with comments" do
    expected = {type: :code, body: 'puts "hello world!" # hey', action: nil}
    line = 'puts "hello world!" # hey'

    result = Chusaku::Parser.parse_line(line: line, actions: %w[foo bar])

    assert_equal(expected, result)
  end
end
