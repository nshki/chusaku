# frozen_string_literal: true

module Chusaku
  # Handles extracting information about the Rails project's routes.
  class Routes
    class << self
      # Example output:
      #
      #   {
      #     'users' => {
      #       'edit' => [
      #         { verb: 'GET', path: '/users/:id', name: 'edit_user' }
      #       ],
      #       'update' => [
      #         { verb: 'PATCH', path: '/users', name: 'edit_user' },
      #         { verb: 'PUT', path: '/users', name: 'edit_user' }
      #       ]
      #     },
      #     'empanadas' => {
      #       'create' => [
      #         { verb: 'POST', path: '/empanadas', name: nil }
      #       ]
      #     }
      #   }
      #
      # @return {Hash} - Routes hash
      def call
        routes = {}

        Rails.application.routes.routes.each do |route|
          controller, action, defaults = extract_data_from(route)
          routes[controller] ||= {}
          routes[controller][action] ||= []

          add_info_for \
            route: route,
            routes: routes,
            controller: controller,
            action: action,
            defaults: defaults
        end

        backfill_routes(routes)
      end

      private

      # Adds formatted route info for the given param combination.
      #
      # @param {Hash} route - Route info
      # @param {Hash} routes - Collection of all route info
      # @param {String} controller - Controller key
      # @param {STring} action - Action key
      # @return {void}
      def add_info_for(route:, routes:, controller:, action:, defaults:)
        verbs_for(route).each do |verb|
          routes[controller][action]
            .push(format(route: route, verb: verb, defaults: defaults))
          routes[controller][action].uniq!
        end
      end

      # Extract the HTTP verbs for a Rails route. Required for older versions of
      # Rails that return regular expressions for a route verb which sometimes
      # contains multiple verbs.
      #
      # @param {ActionDispatch::Journey::Route} route - Route given by Rails
      # @return {Array<String>} - List of HTTP verbs for the given route
      def verbs_for(route)
        route_verb = route.verb.to_s

        %w[GET POST PUT PATCH DELETE].select do |verb|
          route_verb.include?(verb)
        end
      end

      # Formats information for a given route.
      #
      # @param {ActionDispatch::Journey::Route} route - Route given by Rails
      # @param {String} verb - HTTP verb
      # @return {Hash} - { verb: String, path: String, name: String }
      def format(route:, verb:, defaults:)
        {
          verb: verb,
          path: route.path.spec.to_s.gsub('(.:format)', ''),
          name: route.name,
          defaults: defaults
        }
      end

      # Given a routes hash, backfill entries that aren't already filled by
      # `Rails.application.routes`.
      #
      # @param {Hash} routes - Routes hash generated by this class
      # @return {Hash} - Backfilled routes hash
      def backfill_routes(routes)
        paths = {}

        routes.each do |_controller, actions|
          actions.each do |_action, data|
            data.each do |datum|
              paths[datum[:path]] ||= datum[:name]
              datum[:name] ||= paths[datum[:path]]
            end
          end
        end

        routes
      end

      # Given a route, extract the controller and action strings.
      #
      # @param {ActionDispatch::Journey::Route} route - Route instance
      # @return {Array<String>} - [String, String]
      def extract_data_from(route)
        defaults = route.defaults.dup
        controller = defaults.delete(:controller)
        action = defaults.delete(:action)

        [controller, action, defaults]
      end
    end
  end
end
