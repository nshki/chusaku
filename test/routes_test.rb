require_relative "test_helper"

describe "Chusaku::Routes" do
  it "parses routes correctly" do
    expected =
      {
        "api/burritos" => {
          "create" => [
            {
              verb: "POST",
              path: "/api/burritos",
              name: "burritos",
              defaults: {},
              source_path: Api::BurritosController.instance_method(:create).source_location.first
            }
          ]
        },
        "api/cakes" => {
          "inherit" => [
            {
              verb: "GET",
              path: "/api/cakes/inherit",
              name: "inherit",
              defaults: {},
              source_path: Api::CakesController.instance_method(:inherit).source_location.first
            },
            {
              verb: "PUT",
              path: "/api/cakes/inherit",
              name: "inherit",
              defaults: {},
              source_path: Api::CakesController.instance_method(:inherit).source_location.first
            }
          ],
          "index" => [
            {
              verb: "GET",
              path: "/api/cakes",
              name: "cakes",
              defaults: {},
              source_path: Api::CakesController.instance_method(:index).source_location.first
            }
          ]
        },
        "api/croissants" => {
          "index" => [
            {
              verb: "GET",
              path: "/api/croissants",
              name: "croissants",
              defaults: {},
              source_path: Api::CroissantsController.instance_method(:index).source_location.first
            }
          ]
        },
        "api/tacos" => {
          "show" => [
            {
              verb: "GET",
              path: "/",
              name: "root",
              defaults: {},
              source_path: Api::TacosController.instance_method(:show).source_location.first
            },
            {
              verb: "GET",
              path: "/api/tacos/:id",
              name: "taco",
              defaults: {},
              source_path: Api::TacosController.instance_method(:show).source_location.first
            }
          ],
          "create" => [
            {
              verb: "POST",
              path: "/api/tacos",
              name: "tacos",
              defaults: {},
              source_path: Api::TacosController.instance_method(:create).source_location.first
            }
          ],
          "update" => [
            {
              verb: "PUT",
              path: "/api/tacos/:id",
              name: "taco",
              defaults: {},
              source_path: Api::TacosController.instance_method(:update).source_location.first
            },
            {
              verb: "PATCH",
              path: "/api/tacos/:id",
              name: "taco",
              defaults: {},
              source_path: Api::TacosController.instance_method(:update).source_location.first
            }
          ]
        },
        "waterlilies" => {
          "show" => [
            {
              verb: "GET",
              path: "/waterlilies/:id",
              name: "waterlilies",
              defaults: {},
              source_path: WaterliliesController.instance_method(:show).source_location.first
            },
            {
              verb: "GET",
              path: "/waterlilies/:id",
              name: "waterlilies2",
              defaults: {},
              source_path: WaterliliesController.instance_method(:show).source_location.first
            },
            {
              verb: "GET",
              path: "/waterlilies/:id",
              name: "waterlilies_blue",
              defaults: {blue: true},
              source_path: WaterliliesController.instance_method(:show).source_location.first
            }
          ],
          "one_off" => [
            {
              verb: "GET",
              path: "/one-off",
              name: nil,
              defaults: {},
              source_path: WaterliliesController.instance_method(:one_off).source_location.first
            }
          ]
        },
        "cars" => {
          "create" => [
            {
              verb: "POST",
              path: "/engine/cars",
              name: "car",
              defaults: {},
              source_path: CarsController.instance_method(:create).source_location.first
            }
          ]
        }
      }

    result = Chusaku::Routes.call

    assert_equal(expected, result)
  end
end
