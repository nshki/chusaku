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
            names: %w(tacos)
          },
          'show' => {
            verbs: %w(GET),
            path: '/api/tacos/:id',
            names: %w(taco)
          },
          'update' => {
            verbs: %w(PUT PATCH),
            path: '/api/tacos/:id',
            names: %w(taco)
          }
        },
        'waterlilies' => {
          'show' => {
            verbs: %w(GET),
            path: '/waterlilies/:id',
            names: %w(waterlilies waterlilies2)
          },
          'one_off' => {
            verbs: %w(GET),
            path: '/one-off',
            names: %w()
          }
        }
      }
    result = Chusaku::Routes.call
    assert_equal(expected, result)
  end
end
