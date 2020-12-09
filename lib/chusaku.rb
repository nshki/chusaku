# frozen_string_literal: true

require 'chusaku/version'
require 'chusaku/parser'
require 'chusaku/routes'

# Handles core functionality of annotating projects.
module Chusaku
  class << self
    # The main method to run Chusaku. Annotate all actions in a Rails project as
    # follows:
    #
    #   # @route GET /waterlilies/:id (waterlilies)
    #   def show
    #     # ...
    #   end
    #
    # @param {Hash} flags - CLI flags
    # @return {Integer} - 0 on success, 1 on error
    def call(flags = {})
      @flags = flags
      @routes = Chusaku::Routes.call
      @annotated_paths = []
      controllers_pattern = 'app/controllers/**/*_controller.rb'

      Dir.glob(Rails.root.join(controllers_pattern)).each do |path|
        controller = %r{controllers\/(.*)_controller\.rb}.match(path)[1]
        actions = @routes[controller]
        next if actions.nil?

        annotate_file(path: path, controller: controller, actions: actions.keys)
      end

      output_results
    end

    private

    # Adds annotations to the given file.
    #
    # @param {String} path - Path to file
    # @param {String} controller - Controller name
    # @param {Array<String>} actions - List of valid actions for the controller
    # @return {void}
    def annotate_file(path:, controller:, actions:)
      parsed_file = Chusaku::Parser.call(path: path, actions: actions)
      parsed_file[:groups].each_cons(2) do |prev, curr|
        clean_group(prev)
        next unless curr[:type] == :action

        route_data = @routes[controller][curr[:action]]
        next unless route_data.any?

        annotate_group(group: curr, route_data: route_data)
      end

      write_to_file(path: path, parsed_file: parsed_file)
    end

    # Given a parsed group, clean out its contents.
    #
    # @param {Hash} group - { type: Symbol, body: String }
    # @return {void}
    def clean_group(group)
      return unless group[:type] == :comment

      group[:body] = group[:body].gsub(/^\s*#\s*@route.*$\n/, '')
      group[:body] =
        group[:body].gsub(%r{^\s*# (GET|POST|PATCH\/PUT|DELETE) \/\S+$\n}, '')
    end

    # Add an annotation to the given group given by Chusaku::Parser that looks
    # like:
    #
    #   @route GET /waterlilies/:id (waterlilies)
    #
    # @param {Hash} group - Parsed content given by Chusaku::Parser
    # @param {Hash} route_data - Individual route data given by Chusaku::Routes
    # @return {void}
    def annotate_group(group:, route_data:)
      whitespace = /^(\s*).*$/.match(group[:body])[1]
      route_data.reverse_each do |datum|
        comment = "#{whitespace}# #{annotate_route(**datum)}\n"
        group[:body] = comment + group[:body]
      end
    end

    # Generate route annotation.
    #
    # @param {String} verb - HTTP verb for route
    # @param {String} path - Rails path for route
    # @param {String} name - Name used in route helpers
    # @param {Hash} defaults - Default parameters for route
    # @return {String} - "@route <verb> <path> {<defaults>} (<name>)"
    def annotate_route(verb:, path:, name:, defaults:)
      annotation = "@route #{verb} #{path}"
      if defaults&.any?
        defaults_str =
          defaults
          .map { |key, value| "#{key}: #{value.inspect}" }
          .join(', ')
        annotation += " {#{defaults_str}}"
      end
      annotation += " (#{name})" unless name.nil?
      annotation
    end

    # Write annotated content to a file if it differs from the original.
    #
    # @param {String} path - File path to write to
    # @param {Hash} parsed_file - Hash mutated by `annotate_group`
    # @return {void}
    def write_to_file(path:, parsed_file:)
      new_content = new_content_for(parsed_file)
      return unless parsed_file[:content] != new_content

      unless @flags.include?(:dry)
        perform_write(path: path, content: new_content)
      end

      @annotated_paths.push(path)
    end

    # Extracts the new file content for the given parsed file.
    #
    # @param {Hash} parsed_file - { groups: Array<Hash> }
    # @return {String} - New file content
    def new_content_for(parsed_file)
      parsed_file[:groups].map { |pf| pf[:body] }.join
    end

    # Wraps the write operation. Needed to clearly distinguish whether it's a
    # write in the test suite or a write in actual use.
    #
    # @param {String} path - File path
    # @param {String} content - File content
    # @return {void}
    def perform_write(path:, content:)
      File.open(path, file_mode) do |file|
        if file.respond_to?(:test_write)
          file.test_write(content, path)
        else
          file.write(content)
        end
      end
    end

    # When running the test suite, we want to make sure we're not overwriting
    # any files. `r` mode ensures that, and `w` is used for actual usage.
    #
    # @return {String} - 'r' or 'w'
    def file_mode
      File.instance_methods.include?(:test_write) ? 'r' : 'w'
    end

    # Output results to user.
    #
    # @return {Integer} - 0 for success, 1 for error
    def output_results
      if @annotated_paths.any?
        puts("Annotated #{@annotated_paths.join(', ')}")
        @flags.include?(:error_on_annotation) ? 1 : 0
      else
        puts('Nothing to annotate')
        0
      end
    end
  end
end
