require_relative "test_helper"

class RoutesTest < Minitest::Test
  def test_mock_rails
    expected =
      {
        "api/burritos" => {
          "create" => [
            {verb: "POST", path: "/api/burritos", name: "burritos", defaults: {}}
          ]
        },
        "api/cakes" => {
          "inherit" => [
            {verb: "GET", path: "/api/cakes/inherit", name: "inherit", defaults: {}},
            {verb: "PUT", path: "/api/cakes/inherit", name: "inherit", defaults: {}}
          ]
        },
        "api/tacos" => {
          "show" => [
            {verb: "GET", path: "/", name: "root", defaults: {}},
            {verb: "GET", path: "/api/tacos/:id", name: "taco", defaults: {}}
          ],
          "create" => [
            {verb: "POST", path: "/api/tacos", name: "tacos", defaults: {}}
          ],
          "update" => [
            {verb: "PUT", path: "/api/tacos/:id", name: "taco", defaults: {}},
            {verb: "PATCH", path: "/api/tacos/:id", name: "taco", defaults: {}}
          ]
        },
        "waterlilies" => {
          "show" => [
            {verb: "GET", path: "/waterlilies/:id", name: "waterlilies", defaults: {}},
            {verb: "GET", path: "/waterlilies/:id", name: "waterlilies2", defaults: {}},
            {verb: "GET", path: "/waterlilies/:id", name: "waterlilies_blue", defaults: {blue: true}}
          ],
          "one_off" => [
            {verb: "GET", path: "/one-off", name: nil, defaults: {}}
          ]
        },
        "cars" => {
          "create" => [
            {verb: "POST", path: "/engine/cars", name: "car", defaults: {}}
          ]
        }
      }

    result = Chusaku::Routes.call

    assert_equal(expected, result)
  end
end
