require_relative "test_helper"

describe "Chusaku::CLI" do
  it "implements a help flag" do
    # -h
    out, = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(["-h"]))
    end
    assert_match(/Show this help message and quit/, out)

    # --help
    out, = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(["--help"]))
    end
    assert_match(/Show this help message and quit/, out)
  end

  it "implements a version flag" do
    out, = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(["-v"]))
    end
    assert_match(/\d+\.\d+\.\d+/, out)
  end

  it "handles -v and -h flags in any order" do
    # Passing -v before -h executes -v and exits.
    out, = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(["-v", "-h"]))
    end
    assert_match(/\d+\.\d+\.\d+/, out)
    refute_match(/Show this help message and quit/, out)

    # Passing -h before -v executes -h and exits.
    out, = capture_io do
      assert_equal(0, Chusaku::CLI.new.call(["-h", "-v"]))
    end
    assert_match(/Show this help message and quit/, out)
    refute_match(/\d+\.\d+\.\d+/, out)
  end

  it "detects Rails projects" do
    _, err = capture_io do
      assert_equal(1, Chusaku::CLI.new.call(["-c", "**/*_not_controller.rb"]))
    end
    assert_equal(<<~ERR, err)
      Please run chusaku from the root of your project.
    ERR
  end

  it "implements a dry run flag" do
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(0, cli.call(["--dry-run"]))
      end
      assert_equal({dry: true}, cli.options)
    end
  end

  it "implements an exit-on-error flag" do
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(1, cli.call(["--exit-with-error-on-annotation"]))
      end
      assert_equal({error_on_annotation: true}, cli.options)
    end
  end

  it "implements a verbose flag" do
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(0, cli.call(["--verbose"]))
      end
      assert_equal({verbose: true}, cli.options)
    end
  end

  it "implements a controllers pattern flag" do
    # --controllers-pattern
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(0, cli.call(["--controllers-pattern=**/controllers/**/*_controller.rb"]))
      end
      assert_equal({controllers_pattern: "**/controllers/**/*_controller.rb"}, cli.options)
    end

    # -c
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(0, cli.call(["-c", "**/controllers/**/*_controller.rb"]))
      end
      assert_equal({controllers_pattern: "**/controllers/**/*_controller.rb"}, cli.options)
    end
  end

  it "implements an exclusion pattern flag" do
    # --exclusion-pattern
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(0, cli.call(["--exclusion-pattern=**/*_not_controller.rb"]))
      end
      assert_equal({exclusion_pattern: "**/*_not_controller.rb"}, cli.options)
    end

    # -e
    cli = Chusaku::CLI.new
    cli.stub(:check_for_rails_project, nil) do
      capture_io do
        assert_equal(0, cli.call(["-e", "**/*_not_controller.rb"]))
      end
      assert_equal({exclusion_pattern: "**/*_not_controller.rb"}, cli.options)
    end
  end
end
