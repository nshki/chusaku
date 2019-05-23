# frozen_string_literal: true

require 'chusaku/version'

module Chusaku
  class << self
    def annotate
      routes = Rails.application.routes.routes
      actions = parse_data(routes)
    end

    protected

      # Extract relevant information about a given set of routes.
      #
      # @param {ActionDispatch::Journey::Routes} routes
      # @return {Hash}
      def parse_data(routes)
        routes.map do |route|
          {
            verb: route.verb,
            path: route.path.spec.to_s,
            name: route.name,
            controller: route.default[:controller],
            action: route.defaults[:action]
          }
        end
      end
  end
end
