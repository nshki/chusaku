require_relative "test_helper"

class ChusakuTest < Minitest::Test
  def test_dry_run_flag
    File.reset_mock
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call(dry: true) }

    assert_equal(0, exit_code)
    assert_empty(File.written_files)
    assert_includes(out, "This was a dry run so no files were changed.")
  end

  def test_exit_with_error_on_annotation_flag
    File.reset_mock
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call(error_on_annotation: true) }

    assert_equal(1, exit_code)
    assert_equal(2, File.written_files.count)
    assert_includes(out, "Exited with status code 1.")
  end

  def test_dry_run_and_exit_with_error_flag
    File.reset_mock
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call(dry: true, error_on_annotation: true) }

    assert_equal(1, exit_code)
    assert_empty(File.written_files)
    assert_includes(out, "This was a dry run so no files were changed.")
    assert_includes(out, "Exited with status code 1.")
  end

  def test_verbose_flag
    File.reset_mock
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call(verbose: true) }

    assert_equal(0, exit_code)
    assert_includes \
      out,
      <<~CHANGES_COPY
        [test/mock/app/controllers/api/tacos_controller.rb:2]

        Before:
        ```ruby
          def show
        ```

        After:
        ```ruby
          # @route GET / (root)
          # @route GET /api/tacos/:id (taco)
          def show
        ```
      CHANGES_COPY
  end

  def test_mock_app
    File.reset_mock
    exit_code = 0

    capture_io { exit_code = Chusaku.call }
    files = File.written_files
    base_path = "test/mock/app/controllers"

    assert_equal(0, exit_code)
    assert(2, files.count)
    refute_includes(files, "#{base_path}/api/burritos_controller.rb")

    expected =
      <<~HEREDOC
        class TacosController < ApplicationController
          # @route GET / (root)
          # @route GET /api/tacos/:id (taco)
          def show
          end

          # This is an example of generated annotations that come with Rails 6
          # scaffolds. These should be replaced by Chusaku annotations.
          # @route POST /api/tacos (tacos)
          def create
          end

          # Update all the tacos!
          # We should not see a duplicate @route in this comment block.
          # But this should remain (@route), because it's just words.
          # @route PUT /api/tacos/:id (taco)
          # @route PATCH /api/tacos/:id (taco)
          def update
          end

          # This route doesn't exist, so it should be deleted.
          def destroy
            puts("Tacos are indestructible")
          end

          private

          def tacos_params
            params.require(:tacos).permit(:carnitas)
          end
        end
      HEREDOC
    assert_equal(expected, files["#{base_path}/api/tacos_controller.rb"])

    expected =
      <<~HEREDOC
        class WaterliliesController < ApplicationController
          # @route GET /waterlilies/:id (waterlilies)
          # @route GET /waterlilies/:id (waterlilies2)
          # @route GET /waterlilies/:id {blue: true} (waterlilies_blue)
          def show
          end

          # @route GET /one-off
          def one_off
          end
        end
      HEREDOC
    assert_equal(expected, files["#{base_path}/waterlilies_controller.rb"])
  end
end
