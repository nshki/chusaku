# frozen_string_literal: true

module Chusaku
  module Routes
    # Extract information about the Rails project's routes.
    #
    # Example output:
    #
    #   {
    #     'users' => {
    #       'edit'   => { verb: 'GET', path: '/users/:id', name: 'edit_user' },
    #       'update' => { verb: 'PUT', path: '/users',     name: nil }
    #     },
    #     'empanadas' => {
    #       'create' => { verb: 'POST', path: '/empanadas', name: nil }
    #     }
    #   }
    #
    # @return {Hash}
    def self.call
      routes = {}

      Rails.application.routes.routes.each do |route|
        defaults = route.defaults
        action = defaults[:action]

        routes[defaults[:controller]] ||= {}
        routes[defaults[:controller]][action] =
          {
            verb: route.verb,
            path: route.path.spec.to_s.gsub('(.:format)', ''),
            name: route.name
          }
      end

      routes
    end
  end
end
