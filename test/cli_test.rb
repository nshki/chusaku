# frozen_string_literal: true

require 'test_helper'

class Chusaku::CLITest < Minitest::Test
  def test_help_flag
    # -h
    out, _ = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(['-h']))
    end
    assert_match(/Show this help message and quit/, out)

    # --help
    out, _ = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(['--help']))
    end
    assert_match(/Show this help message and quit/, out)
  end

  def test_version_flag
    out, _ = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(['-v']))
    end
    assert_match(/\d+\.\d+\.\d+/, out)
  end

  def test_exit_flag_precedence
    # Passing -v before -h executes -v and exits.
    out, _ = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(['-v', '-h']))
    end
    assert_match(/\d+\.\d+\.\d+/, out)
    refute_match(/Show this help message and quit/, out)

    # Passing -h before -v executes -h and exits.
    out, _ = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(['-h', '-v']))
    end
    assert_match(/Show this help message and quit/, out)
    refute_match(/\d+\.\d+\.\d+/, out)
  end

  def test_project_detection
    _, err = capture_io do
      assert_equal(1, Chusaku::CLI.new.call([]))
    end
    assert_equal(<<~ERR, err)
      Please run chusaku from the root of your project.
    ERR
  end

  def test_dry_flag
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(0, cli.call(['--dry-run']))
      end
      assert_equal({ dry: true }, cli.options)
    end
  end

  def test_exit_with_error_on_annotation_flag
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(1, cli.call(['--exit-with-error-on-annotation']))
      end
      assert_equal({ error_on_annotation: true }, cli.options)
    end
  end
end
