# frozen_string_literal: true

require 'test_helper'

class RoutesTest < Minitest::Test
  def test_mock_rails
    expected =
      {
        'api/tacos' => {
          'create' => {
            verbs: %w(POST),
            path: '/api/tacos',
            names: []
          },
          'update' => {
            verbs: %w(PUT PATCH),
            path: '/api/tacos/:id',
            names: []
          }
        },
        'waterlilies' => {
          'show' => {
            verbs: %w(GET),
            path: '/waterlilies/:id',
            names: %w(waterlilies waterlilies2)
          }
        }
      }
    result = Chusaku::Routes.call
    assert_equal(expected, result)
  end
end
