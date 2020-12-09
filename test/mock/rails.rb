# frozen_string_literal: true

# This file overrides Rails methods such that we can test without installing
# multiple versions of Rails in the test suite. If different versions of Rails
# begin treating route generation differently, new overrides should be written
# for each version.
#
# The mocks used should reflect the files located in `test/mock/app/`.
module Rails
  class << self
    # Lets us call `Rails.application.routes.routes` without a skeleton Rails
    # app.
    #
    # @return {Minitest::Mock} - Mocked `Rails.application`
    def application
      routes = []

      routes.push \
        mock_route \
          controller: 'api/burritos',
          action: 'create',
          verb: 'POST',
          path: '/api/burritos(.:format)',
          name: 'burritos'
      routes.push \
        mock_route \
          controller: 'api/tacos',
          action: 'show',
          verb: 'GET',
          path: '/',
          name: 'root'
      routes.push \
        mock_route \
          controller: 'api/tacos',
          action: 'create',
          verb: 'POST',
          path: '/api/tacos(.:format)',
          name: 'tacos'
      routes.push \
        mock_route \
          controller: 'api/tacos',
          action: 'show',
          verb: 'GET',
          path: '/api/tacos/:id(.:format)',
          name: 'taco'
      routes.push \
        mock_route \
          controller: 'api/tacos',
          action: 'update',
          verb: /^PUT|PATCH$/,
          path: '/api/tacos/:id(.:format)',
          name: nil
      routes.push \
        mock_route \
          controller: 'api/tacos',
          action: 'update',
          verb: 'PUT',
          path: '/api/tacos/:id(.:format)',
          name: nil
      routes.push \
        mock_route \
          controller: 'waterlilies',
          action: 'show',
          verb: 'GET',
          path: '/waterlilies/:id(.:format)',
          name: 'waterlilies'
      routes.push \
        mock_route \
          controller: 'waterlilies',
          action: 'show',
          verb: 'GET',
          path: '/waterlilies/:id(.:format)',
          name: 'waterlilies2'
      routes.push \
        mock_route \
          controller: 'waterlilies',
          action: 'show',
          verb: 'GET',
          path: '/waterlilies/:id(.:format)',
          name: 'waterlilies_blue',
          defaults: { blue: true }
      routes.push \
        mock_route \
          controller: 'waterlilies',
          action: 'one_off',
          verb: 'GET',
          path: '/one-off',
          name: nil

      app = Minitest::Mock.new
      app_routes = Minitest::Mock.new
      app_routes.expect(:routes, routes)
      app.expect(:routes, app_routes)
      app
    end

    # Lets us call `Rails.root` without an skeleton Rails app.
    #
    # @return {Minitest::Mock} - Mocked `Rails.root`
    def root
      rails_root = Minitest::Mock.new
      rails_root.expect \
        :join,
        'test/mock/app/controllers/**/*_controller.rb',
        [String]
      rails_root
    end

    private

    # Stored procedure for mocking a new route.
    #
    # @param {String} controller - Mocked controller name
    # @param {String} action - Mocked action name
    # @param {String} verb - HTTP verb
    # @param {String} path - Mocked Rails path
    # @param {String} name - Mocked route name
    # @param {Hash} defaults - Mocked default params
    # @return {Minitest::Mock} - Mocked route
    def mock_route(controller:, action:, verb:, path:, name:, defaults: {})
      route = Minitest::Mock.new
      route.expect(:defaults, controller: controller, action: action, **defaults)
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
