module RouteHelper
  # Define an allowlist of controller/actions that will be mocked.
  #
  # @param route_allowlist [Array<String>] In format "controller#action"
  # @return [void]
  def set_route_allowlist(route_allowlist)
    @@route_allowlist = route_allowlist
  end

  # Builds a mock `Rails.application`.
  #
  # @param routes [Array<Minitest::Mock>] Routes to include
  # @return [Minitest::Mock] Mocked application
  def mock_app(routes:)
    mock_routes = Minitest::Mock.new
    mock_routes.expect(:routes, routes.compact)
    app = Minitest::Mock.new
    app.expect(:routes, mock_routes)
    app
  end

  # Stored procedure for mocking a new route.
  #
  # @param controller [String] Mocked controller name
  # @param action [String] Mocked action name
  # @param verb [String] HTTP verb
  # @param path [String] Mocked Rails path
  # @param name [String] Mocked route name
  # @param engines [Boolean] Whether engines are mocked or not
  # @param defaults [Hash] Mocked default params
  # @return [Minitest::Mock, nil] Mocked route
  def mock_route(controller:, action:, verb:, path:, name:, engines: true, defaults: {})
    @@route_allowlist ||= []
    return if @@route_allowlist.any? && @@route_allowlist.index("#{controller}##{action}").nil?

    app = Minitest::Mock.new
    app.expect(:engine?, false) if engines

    route = Minitest::Mock.new
    route.expect(:defaults, {controller: controller, action: action, **defaults})
    route.expect(:verb, verb)
    2.times { route.expect(:app, app) } # Accessed twice in `Chusaku::Routes.populate_routes`
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

  # Stored procedure to mock a new engine.
  #
  # @param engine [Module] Mocked engine module
  # @param path [String] Path for mocked engine
  # @return [Minitest::Mock]
  def mock_engine(engine:, path:)
    route = Minitest::Mock.new

    # We'll be calling these particular methods more than once to test for
    # duplicate-removal, hence wrapping in `.times` block.
    3.times do
      route.expect(:app, engine)
    end

    route
  end
end
