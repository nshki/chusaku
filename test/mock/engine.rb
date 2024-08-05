# This file overrides Rails methods such that we can test without installing
# multiple versions of Rails in the test suite. If different versions of Rails
# begin treating route generation differently, new overrides should be written
# for each version.
#
# The mocks used should reflect the files located in `test/mock/app/`.

require "pathname"
require_relative "route_helper"
require_relative "engine/app/controllers/engine_controller"
require_relative "engine/app/controllers/cars_controller"

module Engine
  extend RouteHelper

  class << self
    # Lets us call `Engine.app.routes.routes` without a skeleton Rails
    # app.
    #
    # @return [Minitest::Mock] Mocked `Engine.app`
    def app
      routes = []

      routes.push \
        mock_route \
          controller: "cars",
          action: "create",
          verb: "POST",
          path: "/engine/cars(.:format)",
          name: "car"

      app = Minitest::Mock.new
      app_routes = Minitest::Mock.new
      app_routes.expect(:routes, routes.compact)
      app.expect(:routes, app_routes)
      app
    end

    # Lets us call `Engine.engine?` without a skeleton Rails app.
    #
    # @return [Boolean]
    def engine?
      true
    end
  end
end
