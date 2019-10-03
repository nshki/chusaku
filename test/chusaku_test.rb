# frozen_string_literal: true

require 'test_helper'

class ChusakuTest < Minitest::Test
  def test_mock_app
    Chusaku.call
    files = File.written_files
    base_path = 'test/mock/app/controllers'

    expected =
      <<~HEREDOC
        # frozen_string_literal: true

        class TacosController < ApplicationController
          # @route [POST] /api/tacos
          def create; end

          # Update all the tacos!
          # We should not see a duplicate @route in this comment block.
          # But this should remain (@route), because it's just words.
          # @route [PUT, PATCH] /api/tacos/:id
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
          # @route [GET] /waterlilies/:id (waterlilies, waterlilies2)
          def show; end
        end
      HEREDOC
    assert_equal(expected, files["#{base_path}/waterlilies_controller.rb"])
  end
end
