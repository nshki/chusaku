# frozen_string_literal: true

require 'test_helper'

class RoutesTest < Minitest::Test
  def test_mock_rails
    expected =
      {
        'api/tacos' => {
          'show' => [
            { verb: 'GET', path: '/', name: 'root' },
            { verb: 'GET', path: '/api/tacos/:id', name: 'taco' }],
          'create' => [
            { verb: 'POST', path: '/api/tacos', name: 'tacos' }],
          'update' => [
            { verb: 'PUT', path: '/api/tacos/:id', name: 'taco' },
            { verb: 'PATCH', path: '/api/tacos/:id', name: 'taco' }]
        },
        'waterlilies' => {
          'show' => [
            { verb: 'GET', path: '/waterlilies/:id', name: 'waterlilies' },
            { verb: 'GET', path: '/waterlilies/:id', name: 'waterlilies2' }],
          'one_off' => [
            { verb: 'GET', path: '/one-off', name: nil }]
        }
      }

    result = Chusaku::Routes.call

    assert_equal(expected, result)
  end
end
