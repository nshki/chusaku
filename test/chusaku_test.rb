require_relative "test_helper"

class ChusakuTest < Minitest::Test
  def test_dry_run_flag
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call(dry: true) }

    assert_equal(0, exit_code)
    assert_empty(File.written_files)
    assert_includes(out, "This was a dry run so no files were changed.")
  end

  def test_exit_with_error_on_annotation_flag
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call(error_on_annotation: true) }

    assert_equal(1, exit_code)
    assert_equal(3, File.written_files.count)
    assert_includes(out, "Exited with status code 1.")
  end

  def test_dry_run_and_exit_with_error_flag
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call(dry: true, error_on_annotation: true) }

    assert_equal(1, exit_code)
    assert_empty(File.written_files)
    assert_includes(out, "This was a dry run so no files were changed.")
    assert_includes(out, "Exited with status code 1.")
  end

  def test_verbose_flag
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call(verbose: true) }

    assert_equal(0, exit_code)
    refute_includes(out, "Annotated #{Rails.root}/app/controllers/api/burritos_controller.rb")
    assert_includes(out, "Annotated #{Rails.root}/app/controllers/api/cakes_controller.rb")
    assert_includes(out, "Annotated #{Rails.root}/app/controllers/api/tacos_controller.rb")
    assert_includes(out, "Annotated #{Rails.root}/app/controllers/waterlilies_controller.rb")
  end

  def test_mock_app
    exit_code = 0

    capture_io { exit_code = Chusaku.call }
    files = File.written_files
    base_path = "#{Rails.root}/app/controllers"

    assert_equal(0, exit_code)
    assert_equal(3, files.count)
    refute_includes(files, "#{base_path}/api/burritos_controller.rb")

    expected =
      <<~HEREDOC
        module Api
          class CakesController < ApplicationController
            # This route's GET action should be named the same as its PUT action,
            # even though only the PUT action is named.
            # @route GET /api/cakes/inherit (inherit)
            # @route PUT /api/cakes/inherit (inherit)
            def inherit
            end
          end
        end
      HEREDOC
    assert_equal(expected, files["#{base_path}/api/cakes_controller.rb"])

    expected =
      <<~HEREDOC
        module Api
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

  def test_mock_app_with_no_pending_annotations
    Rails.set_route_allowlist(["api/burritos#create"])
    exit_code = 0

    out, _err = capture_io { exit_code = Chusaku.call }

    assert_equal(0, exit_code)
    assert_empty(File.written_files)
    assert_equal("Controller files unchanged.\n", out)
  end

  def test_mock_app_with_non_matching_controllers_pattern
    exit_code = 0

    args = {controllers_pattern: "**/nomatch/*_controller.rb"}
    out, = capture_io { exit_code = Chusaku.call(args) }

    assert_equal(0, exit_code)
    assert_empty(File.written_files)
    assert_equal("Controller files unchanged.\n", out)
  end
end
