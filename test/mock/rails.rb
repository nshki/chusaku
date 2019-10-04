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

    # Mock tacos#create route.
    taco_create = Minitest::Mock.new
    taco_create.expect(:defaults, controller: 'api/tacos', action: 'create')
    taco_create.expect(:verb, 'POST')
    taco_create_path = Minitest::Mock.new
    taco_create_path.expect(:spec, '/api/tacos(.:format)')
    taco_create.expect(:path, taco_create_path)
    taco_create.expect(:name, 'tacos')
    routes.push(taco_create)

    # Mock tacos#show route.
    taco_index = Minitest::Mock.new
    taco_index.expect(:defaults, controller: 'api/tacos', action: 'show')
    taco_index.expect(:verb, 'GET')
    taco_index_path = Minitest::Mock.new
    taco_index_path.expect(:spec, '/api/tacos/:id(.:format)')
    taco_index.expect(:path, taco_index_path)
    taco_index.expect(:name, nil)
    routes.push(taco_index)

    # Mock tacos#update PUT route.
    taco_update = Minitest::Mock.new
    taco_update.expect(:defaults, controller: 'api/tacos', action: 'update')
    taco_update.expect(:verb, 'PUT')
    taco_update_path = Minitest::Mock.new
    taco_update_path.expect(:spec, '/api/tacos/:id(.:format)')
    taco_update.expect(:path, taco_update_path)
    taco_update.expect(:name, 'taco')
    routes.push(taco_update)

    # Mock tacos#update PATCH route.
    taco_patch = Minitest::Mock.new
    taco_patch.expect(:defaults, controller: 'api/tacos', action: 'update')
    taco_patch.expect(:verb, 'PATCH')
    taco_patch_path = Minitest::Mock.new
    taco_patch_path.expect(:spec, '/api/tacos/:id(.:format)')
    taco_patch.expect(:path, taco_patch_path)
    taco_patch.expect(:name, nil)
    routes.push(taco_patch)

    # Mock waterlilies#show route.
    wl_show = Minitest::Mock.new
    wl_show.expect(:defaults, controller: 'waterlilies', action: 'show')
    wl_show.expect(:verb, 'GET')
    wl_show_path = Minitest::Mock.new
    wl_show_path.expect(:spec, '/waterlilies/:id(.:format)')
    wl_show.expect(:path, wl_show_path)
    wl_show.expect(:name, 'waterlilies')
    routes.push(wl_show)

    # Mock a second waterlilies#show route.
    wl_show = Minitest::Mock.new
    wl_show.expect(:defaults, controller: 'waterlilies', action: 'show')
    wl_show.expect(:verb, 'GET')
    wl_show_path = Minitest::Mock.new
    wl_show_path.expect(:spec, '/waterlilies/:id(.:format)')
    wl_show.expect(:path, wl_show_path)
    wl_show.expect(:name, 'waterlilies2')
    routes.push(wl_show)

    # Mock one-off route with no name.
    one_off = Minitest::Mock.new
    one_off.expect(:defaults, controller: 'waterlilies', action: 'one_off')
    one_off.expect(:verb, 'GET')
    one_off_path = Minitest::Mock.new
    one_off_path.expect(:spec, '/one-off')
    one_off.expect(:path, one_off_path)
    one_off.expect(:name, nil)
    routes.push(one_off)

    # Mock Rails methods.
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
end
