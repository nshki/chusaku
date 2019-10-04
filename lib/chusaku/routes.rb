# frozen_string_literal: true

module Chusaku
  module Routes
    # Extract information about the Rails project's routes.
    #
    # Example output:
    #
    #   {
    #     'users' => {
    #       'edit' => {
    #         verbs: ['GET'],
    #         path: '/users/:id',
    #         names: ['edit_user']
    #       },
    #       'update' => {
    #         verbs: ['PUT', 'PATCH'],
    #         path: '/users', 
    #         names: ['edit_user', 'edit_user2']
    #       }
    #     },
    #     'empanadas' => {
    #       'create' => {
    #         verbs: ['POST'],
    #         path: '/empanadas',
    #         names: []
    #       }
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
          # Add the verb. Ensure the list has no duplicates or `nil` entries.
          routes[controller][action][:verbs].push(route.verb)
          routes[controller][action][:verbs] =
            routes[controller][action][:verbs].uniq.compact

          # Add the name. Ensure the list has no duplicates or `nil` entries.
          routes[controller][action][:names].push(route.name)
          routes[controller][action][:names] =
            routes[controller][action][:names].uniq.compact
        end
      end

      backfill_names_by_path(routes)
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
          names: [route.name].compact
        }
      end

      # Given a formatted routes object, backfill each action's names by path.
      #
      # @param {Hash} routes
      # @return {Hash}
      def self.backfill_names_by_path(routes)
        paths = {}

        # Populate list of names by path.
        routes.each do |_controller, actions|
          actions.each do |action, data|
            paths[data[:path]] ||= []
            data[:names].each { |name| paths[data[:path]].push(name) }
          end
        end

        # Backfill.
        routes.each do |_controller, actions|
          actions.each { |_action, data| data[:names] = paths[data[:path]] }
        end
      end
  end
end
