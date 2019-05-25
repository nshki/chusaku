# frozen_string_literal: true

require 'test_helper'
require 'mock/rails'
require 'mock/file'

class ChusakuTest < Minitest::Test
  def test_mock_app
    Chusaku.call
    files = File.written_files
    base_path = 'test/mock/app/controllers'

    expected =
      <<~HEREDOC
        # frozen_string_literal: true

        class TacosController < ApplicationController
          # @route POST /api/tacos
          def create; end

          # @route PUT /api/tacos/:id
          def update; end
        end
      HEREDOC
    assert_equal(expected, files["#{base_path}/api/tacos_controller.rb"])

    expected =
      <<~HEREDOC
        # frozen_string_literal: true

        class WaterliliesController < ApplicationController
          # @route GET /waterlilies/:id (waterlilies)
          def show; end
        end
      HEREDOC
    assert_equal(expected, files["#{base_path}/waterlilies_controller.rb"])
  end
end
