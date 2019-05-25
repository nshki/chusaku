# frozen_string_literal: true

require 'chusaku/version'
require 'chusaku/parser'
require 'chusaku/routes'

module Chusaku
  # The main method to run Chusaku. Annotate all actions in your Rails project
  # as follows:
  #
  #   # @route GET /waterlilies/:id (waterlilies)
  #   def show
  #     # ...
  #   end
  def self.call
    puts 'Chusaku starting...'
    routes = Chusaku::Routes.call
    controllers = 'app/controllers/**/*_controller.rb'

    # Loop over all controller file paths.
    Dir.glob(Rails.root.join(controllers)).each do |path|
      controller = /controllers\/(.*)_controller\.rb/.match(path)[1]
      actions = routes[controller]
      next if actions.nil?

      # Parse the file and iterate over the parsed content, two entries at a
      # time.
      parsed_file = Chusaku::Parser.call(path: path, actions: actions.keys)
      parsed_file.each_cons(2) do |prev, curr|
        # Remove all @route comments in the previous group.
        if prev[:type] == :comment
          prev[:body] = prev[:body].gsub(/^\s*#\s*@route.*$\n/, '')
        end

        # Only proceed if we are currently looking at an action.
        next unless curr[:type] == :action

        # Insert annotation comment.
        action = curr[:action]
        annotation = annotate(routes[controller][action])
        whitespace = /^(\s*).*$/.match(curr[:body])[1]
        comment = "#{whitespace}# #{annotation}\n"
        curr[:body] = comment + curr[:body]
      end

      # Write to file.
      parsed_content = parsed_file.map { |pf| pf[:body] }
      write(path, parsed_content.join)
      puts "Annotated #{controller}"
    end

    puts 'Chusaku finished!'
  end

  # Write given content to a file. If we're using an overridden version of File,
  # then use its method instead for testing purposes.
  #
  # @param {String} path
  # @param {String} content
  # @return {void}
  def self.write(path, content)
    File.open(path, 'r+') do |file|
      if file.respond_to?(:test_write)
        file.test_write(content, path)
      else
        file.write(content)
      end
    end
  end

  # Given a hash describing an action, generate an annotation in the form:
  #
  #   @route GET /waterlilies/:id (waterlilies)
  #
  # @param {Hash} action_info
  # @return {String}
  def self.annotate(action_info)
    verb = action_info[:verb]
    path = action_info[:path]
    name = action_info[:name]
    annotation = "@route #{verb} #{path}"
    annotation += " (#{name})" unless name.nil?
    annotation
  end
end
