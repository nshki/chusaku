# frozen_string_literal: true

require 'test_helper'

class ChusakuTest < Minitest::Test
  def test_dry_run_flag
    File.reset_mock

    capture_io { Chusaku.call(dry: true) }

    assert_empty(File.written_files)
  end

  def test_exit_with_error_on_annotation_flag
    File.reset_mock

    capture_io do
      assert_equal(1, Chusaku.call(error_on_annotation: true))
    end

    assert_equal(2, File.written_files.size)
  end

  def test_mock_app
    File.reset_mock

    capture_io { Chusaku.call }
    files = File.written_files
    base_path = 'test/mock/app/controllers'

    refute_includes(files, "#{base_path}/api/burritos_controller.rb")

    expected =
      <<~HEREDOC
        # frozen_string_literal: true

        class TacosController < ApplicationController
          # @route GET / (root)
          # @route GET /api/tacos/:id (taco)
          def show; end

          # This is an example of generated annotations that come with Rails 6
          # scaffolds. These should be replaced by Chusaku annotations.
          # @route POST /api/tacos (tacos)
          def create; end

          # Update all the tacos!
          # We should not see a duplicate @route in this comment block.
          # But this should remain (@route), because it's just words.
          # @route PUT /api/tacos/:id (taco)
          # @route PATCH /api/tacos/:id (taco)
          def update; end

          # This route doesn't exist, so it should be deleted.
          def destroy
            puts('Tacos are indestructible')
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
        # frozen_string_literal: true

        class WaterliliesController < ApplicationController
          # @route GET /waterlilies/:id (waterlilies)
          # @route GET /waterlilies/:id (waterlilies2)
          def show; end

          # @route GET /one-off
          def one_off; end
        end
      HEREDOC
    assert_equal(expected, files["#{base_path}/waterlilies_controller.rb"])
  end
end
