# This file overrides Rails methods such that we can test without installing
# multiple versions of Rails in the test suite. If different versions of Rails
# begin treating route generation differently, new overrides should be written
# for each version.
#
# The mocks used should reflect the files located in `test/mock/app/`.

require "pathname"

module Rails
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

      app = Minitest::Mock.new
      app_routes = Minitest::Mock.new
      app_routes.expect(:routes, routes.compact)
      app.expect(:routes, app_routes)
      app
    end

    # Define an allowlist of controller/actions that will be mocked.
    #
    # @param route_allowlist [Array<String>] In format "controller#action"
    # @return [void]
    def set_route_allowlist(route_allowlist)
      @@route_allowlist = route_allowlist
    end

    # Lets us call `Rails.root` without a skeleton Rails app.
    #
    # @return [Pathname] Pathname object like Rails.root
    def root
      Pathname.new("test/mock")
    end

    private

    # Stored procedure for mocking a new route.
    #
    # @param controller [String] Mocked controller name
    # @param action [String] Mocked action name
    # @param verb [String] HTTP verb
    # @param path [String] Mocked Rails path
    # @param name [String] Mocked route name
    # @param defaults [Hash] Mocked default params
    # @return [Minitest::Mock, nil] Mocked route
    def mock_route(controller:, action:, verb:, path:, name:, defaults: {})
      @@route_allowlist ||= []
      return if @@route_allowlist.any? && @@route_allowlist.index("#{controller}##{action}").nil?

      route = Minitest::Mock.new
      route.expect(:defaults, {controller: controller, action: action, **defaults})
      route.expect(:verb, verb)
      route_path = Minitest::Mock.new

      # We'll be calling these particular methods more than once to test for
      # duplicate-removal, hence wrapping in `.times` block.
      2.times do
        route_path.expect(:spec, path)
        route.expect(:path, route_path)
        route.expect(:name, name)
      end

      route
    end
  end
end
