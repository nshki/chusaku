# frozen_string_literal: true

# This file overrides Rails methods such that we can test without installing
# multiple versions of Rails in the test suite. If different versions of Rails
# begin treating route generation differently, new overrides should be written
# for each version.
#
# The mocks used should reflect the files located in `test/mock/app/`.
module Rails
  def self.application
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
        verb: 'PUT',
        path: '/api/tacos/:id(.:format)',
        name: nil
    routes.push \
      mock_route \
        controller: 'api/tacos',
        action: 'update',
        verb: 'PATCH',
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

  def self.root
    rails_root = Minitest::Mock.new
    rails_root.expect \
      :join,
      'test/mock/app/controllers/**/*_controller.rb',
      [String]
    rails_root
  end

  def self.mock_route(controller:, action:, verb:, path:, name:)
    route = Minitest::Mock.new
    route.expect(:defaults, controller: controller, action: action)
    route.expect(:verb, verb)
    route_path = Minitest::Mock.new
    route_path.expect(:spec, path)
    route.expect(:path, route_path)
    route.expect(:name, name)
    route
  end
end
