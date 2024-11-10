# This file overrides Rails methods such that we can test without installing
# multiple versions of Rails in the test suite. If different versions of Rails
# begin treating route generation differently, new overrides should be written
# for each version.
#
# The mocks used should reflect the files located in `test/mock/app/`.

require "pathname"
require_relative "engine"
require_relative "route_helper"

require_relative "app/controllers/application_controller"
require_relative "app/controllers/pastries_controller"
require_relative "app/controllers/waterlilies_controller"
require_relative "app/controllers/api/burritos_controller"
require_relative "app/controllers/api/cakes_controller"
require_relative "app/controllers/api/croissants_controller"
require_relative "app/controllers/api/tacos_controller"

module Rails
  extend RouteHelper

  class << self
    # Lets us call `Rails.application.routes.routes` without a skeleton Rails
    # app.
    #
    # @return [Minitest::Mock] Mocked `Rails.application`
    def application
      routes = []

      routes.push \
        mock_route \
          controller: "api/burritos",
          action: "create",
          verb: "POST",
          path: "/api/burritos(.:format)",
          name: "burritos"
      routes.push \
        mock_route \
          controller: "api/cakes",
          action: "inherit",
          verb: "GET",
          path: "/api/cakes/inherit(.:format)",
          name: nil
      routes.push \
        mock_route \
          controller: "api/cakes",
          action: "inherit",
          verb: "PUT",
          path: "/api/cakes/inherit(.:format)",
          name: "inherit"
      routes.push \
        mock_route \
          controller: "api/cakes",
          action: "index",
          verb: "GET",
          path: "/api/cakes(.:format)",
          name: "cakes"
      routes.push \
        mock_route \
          controller: "api/croissants",
          action: "index",
          verb: "GET",
          path: "/api/croissants(.:format)",
          name: "croissants"
      routes.push \
        mock_route \
          controller: "api/tacos",
          action: "show",
          verb: "GET",
          path: "/",
          name: "root"
      routes.push \
        mock_route \
          controller: "api/tacos",
          action: "create",
          verb: "POST",
          path: "/api/tacos(.:format)",
          name: "tacos"
      routes.push \
        mock_route \
          controller: "api/tacos",
          action: "show",
          verb: "GET",
          path: "/api/tacos/:id(.:format)",
          name: "taco"
      routes.push \
        mock_route \
          controller: "api/tacos",
          action: "update",
          verb: /^PUT|PATCH$/,
          path: "/api/tacos/:id(.:format)",
          name: nil
      routes.push \
        mock_route \
          controller: "api/tacos",
          action: "update",
          verb: "PUT",
          path: "/api/tacos/:id(.:format)",
          name: nil
      routes.push \
        mock_route \
          controller: "waterlilies",
          action: "show",
          verb: "GET",
          path: "/waterlilies/:id(.:format)",
          name: "waterlilies"
      routes.push \
        mock_route \
          controller: "waterlilies",
          action: "show",
          verb: "GET",
          path: "/waterlilies/:id(.:format)",
          name: "waterlilies2"
      routes.push \
        mock_route \
          controller: "waterlilies",
          action: "show",
          verb: "GET",
          path: "/waterlilies/:id(.:format)",
          name: "waterlilies_blue",
          defaults: {blue: true}
      routes.push \
        mock_route \
          controller: "waterlilies",
          action: "one_off",
          verb: "GET",
          path: "/one-off",
          name: nil
      routes.push \
        mock_engine \
          engine: Engine,
          path: "/engine"

      app = Minitest::Mock.new
      app_routes = Minitest::Mock.new
      app_routes.expect(:routes, routes.compact)
      app.expect(:routes, app_routes)
      app
    end

    # Lets us call `Rails.root` without a skeleton Rails app.
    #
    # @return [Pathname] Pathname object like Rails.root
    def root
      Pathname.new("test/mock").realpath
    end
  end
end
