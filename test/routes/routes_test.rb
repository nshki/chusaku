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
            name: nil
          },
          'update' => {
            verbs: %w(PUT PATCH),
            path: '/api/tacos/:id',
            name: nil
          }
        },
        'waterlilies' => {
          'show' => {
            verbs: %w(GET),
            path: '/waterlilies/:id',
            name: 'waterlilies'
          }
        }
      }
    result = Chusaku::Routes.call
    assert_equal(expected, result)
  end
end
