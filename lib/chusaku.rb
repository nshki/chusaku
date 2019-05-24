# frozen_string_literal: true

require 'chusaku/version'

module Chusaku
  # The main method to run Chusaku. Annotate all controller files in your Rails
  # project as follows:
  #
  #   # @route GET /waterlilies/:id (waterlily)
  #   def show
  #     # ...
  #   end
  def self.annotate
    routes = Rails.application.routes.routes
    actions = parse_data(routes)
    controller_paths = Dir.glob \
      Rails.root.join('app/controllers/**/*_controller.rb')

    puts 'Chusaku starting...'

    # Loop over all controller files in the Rails project.
    controller_paths.each do |path|
      controller_key = /controllers\/(.*)_controller.rb/.match(path)[1]
      controller_actions = actions[controller_key]
      next if controller_actions.nil?

      # Annotate lines that contain an action definition.
      File.open(path, 'r+') do |file|
        lines = file.each_line.to_a
        annotated_lines =
          lines.map { |line| create_comment(line, controller_actions) }
        file.rewind
        file.write(annotated_lines.join)
        puts "Annotated #{controller_key}"
      end
    end

    puts 'Chusaku finished!'
  end

  # Extract relevant information about a given set of routes.
  #
  # @param {ActionDispatch::Journey::Routes} routes
  # @return {Hash}
  def self.parse_data(routes)
    data = {}

    routes.each do |route|
      defaults = route.defaults
      action = defaults[:action]
      data[defaults[:controller]] ||= {}
      data[defaults[:controller]][action] =
        {
          verb: route.verb,
          path: route.path.spec.to_s,
          name: route.name
        }
    end

    data
  end

  # Given a line, return a string that represents what should be written in
  # place of that line with a route annotation.
  #
  # @param {String} line
  # @param {Hash} actions
  # @return {String}
  def self.create_comment(line, actions)
    match = /^(\s*)def\s+(\w*).*$/.match(line)
    return line if match.nil?

    whitespace = match[1]
    action = match[2]
    return line if actions[action].nil?

    verb = actions[action][:verb]
    path = actions[action][:path]
    name = actions[action][:name]
    comment = "#{whitespace}# @route #{verb} #{path} (#{name})\n"

    "#{comment}#{line}"
  end
end
