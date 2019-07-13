# frozen_string_literal: true

module Chusaku
  module Routes
    # Extract information about the Rails project's routes.
    #
    # Example output:
    #
    #   {
    #     'users' => {
    #       'edit'   => { verbs: 'GET', path: '/users/:id', name: 'edit_user' },
    #       'update' => { verbs: 'PUT', path: '/users',     name: nil }
    #     },
    #     'empanadas' => {
    #       'create' => { verbs: 'POST', path: '/empanadas', name: nil }
    #     }
    #   }
    #
    # @return {Hash}
    def self.call
      routes = {}

      Rails.application.routes.routes.each do |route|
        defaults = route.defaults
        controller = defaults[:controller]
        action = defaults[:action]

        routes[controller] ||= {}
        if routes[controller][action].nil?
          routes[controller][action] = format_action(route)
        else
          routes[controller][action][:verbs].push(route.verb)
        end
      end

      routes
    end

    private

      # Extract information of a given route.
      #
      # @param {ActionDispatch::Journey::Route} route
      # @return {Hash}
      def self.format_action(route)
        {
          verbs: [route.verb],
          path: route.path.spec.to_s.gsub('(.:format)', ''),
          name: route.name
        }
      end
  end
end
