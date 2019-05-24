# frozen_string_literal: true

require 'test_helper'
require 'mock/rails'
require 'mock/file'

class ChusakuTest < Minitest::Test
  def test_annotate
    Chusaku.annotate
    files = File.written_files
    base_path = 'test/mock/app/controllers'

    expected =
      <<~HEREDOC
        # frozen_string_literal: true

        class TacosController < ApplicationController
          # @route POST /api/tacos (api_taco)
          def create; end

          # @route PUT /api/tacos/:id (api_tacos)
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

  def test_parse_data
    routes = []

    # Mock route1.
    route1 = Minitest::Mock.new
    route1.expect(:defaults, controller: 'controller1', action: 'action1')
    route1.expect(:verb, 'GET')
    route1_path = Minitest::Mock.new
    route1_path.expect(:spec, 'path1(.:format)')
    route1.expect(:path, route1_path)
    route1.expect(:name, 'name1')
    routes.push(route1)

    # Mock route2.
    route2 = Minitest::Mock.new
    route2.expect(:defaults, controller: 'controller2', action: 'action2')
    route2.expect(:verb, 'POST')
    route2_path = Minitest::Mock.new
    route2_path.expect(:spec, 'path2(.:format)')
    route2.expect(:path, route2_path)
    route2.expect(:name, 'name2')
    routes.push(route2)

    result = Chusaku.parse_data(routes)

    expected =
      {
        'controller1' => {
          'action1' => { verb: 'GET', path: 'path1', name: 'name1' }
        },
        'controller2' => {
          'action2' => { verb: 'POST', path: 'path2', name: 'name2' }
        }
      }
    assert_equal(expected, result)
  end

  def test_create_comment
    actions =
      {
        'my_method' => { verb: 'GET', path: 'path1', name: 'name1' },
        'my_other_method' => { verb: 'POST', path: 'path2', name: nil }
      }

    # Valid action.
    line = '  def my_method'
    result = Chusaku.create_comment(line, actions)
    assert_equal("  # @route GET path1 (name1)\n  def my_method", result)

    # Non-method line.
    line = '  raise Exception'
    result = Chusaku.create_comment(line, actions)
    assert_equal('  raise Exception', result)

    # Non-existent action.
    line = 'def test'
    result = Chusaku.create_comment(line, actions)
    assert_equal('def test', result)

    # Commented out action.
    line = '# def my_method'
    result = Chusaku.create_comment(line, actions)
    assert_equal('# def my_method', result)

    # Action with tabs.
    line = '	def my_method'
    result = Chusaku.create_comment(line, actions)
    assert_equal("	# @route GET path1 (name1)\n	def my_method", result)

    # Single-line action.
    line = 'def my_method; end'
    result = Chusaku.create_comment(line, actions)
    assert_equal("# @route GET path1 (name1)\ndef my_method; end", result)

    # Action with no prefix.
    line = 'def my_other_method'
    result = Chusaku.create_comment(line, actions)
    assert_equal("# @route POST path2\ndef my_other_method", result)
  end
end
