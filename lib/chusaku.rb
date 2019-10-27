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
  #
  # @param {Array<String>} args - CLI flags
  # @return {Integer} 0 on success, 1 on error
  def self.call(args = [])
    routes = Chusaku::Routes.call
    controller_pattern = 'app/controllers/**/*_controller.rb'
    controller_paths = Dir.glob(Rails.root.join(controller_pattern))
    annotated_paths = []

    # Loop over all controller file paths.
    controller_paths.each do |path|
      controller = /controllers\/(.*)_controller\.rb/.match(path)[1]
      actions = routes[controller]
      next if actions.nil?

      # Parse the file and iterate over the parsed content, two entries at a
      # time.
      parsed_file = Chusaku::Parser.call(path: path, actions: actions.keys)
      parsed_file[:groups].each_cons(2) do |prev, curr|
        # Remove all @route comments in the previous group.
        if prev[:type] == :comment
          prev[:body] = prev[:body].gsub(/^\s*#\s*@route.*$\n/, '')
        end

        # Only proceed if we are currently looking at an action.
        next unless curr[:type] == :action

        # Fetch current action in routes.
        action = curr[:action]
        data = routes[controller][action]
        next unless data.any?

        # Add annotations.
        whitespace = /^(\s*).*$/.match(curr[:body])[1]
        data.reverse.each do |datum|
          annotation = annotate(datum)
          comment = "#{whitespace}# #{annotation}\n"
          curr[:body] = comment + curr[:body]
        end
      end

      # Write to file.
      parsed_content = parsed_file[:groups].map { |pf| pf[:body] }
      new_content = parsed_content.join
      if parsed_file[:content] != new_content
        write(path, new_content) unless args.include?(:dry)
        annotated_paths << path
      end
    end

    # Output results to user.
    if annotated_paths.any?
      puts "Annotated #{annotated_paths.join(', ')}"
      if args.include?(:error_on_annotation)
        1
      else
        0
      end
    else
      puts "Nothing to annotate"
      0
    end
  end

  # Write given content to a file. If we're using an overridden version of File,
  # then use its method instead for testing purposes.
  #
  # @param {String} path - File path to write to
  # @param {String} content - Contents of the file
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
  # @param {Hash} action_info - Parsed line given by Chusaku::Parser
  # @return {String} Annotation for given parsed line
  def self.annotate(action_info)
    verb = action_info[:verb]
    path = action_info[:path]
    name = action_info[:name]
    annotation = "@route #{verb} #{path}"
    annotation += " (#{name})" unless name.nil?
    annotation
  end
end
