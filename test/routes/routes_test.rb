# frozen_string_literal: true

require 'test_helper'
require 'mock/rails'

class RoutesTest < Minitest::Test
  def test_mock_rails
    expected =
      {
        'api/tacos' => {
          'create' => { verb: 'POST', path: '/api/tacos', name: nil },
          'update' => { verb: 'PUT', path: '/api/tacos/:id', name: nil }
        },
        'waterlilies' => {
          'show' => {
            verb: 'GET',
            path: '/waterlilies/:id',
            name: 'waterlilies'
          }
        }
      }
    result = Chusaku::Routes.call
    assert_equal(expected, result)
  end
end
