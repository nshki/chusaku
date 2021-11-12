# frozen_string_literal: true

require "chusaku/version"
require "chusaku/parser"
require "chusaku/routes"

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
    # @param flags [Hash] CLI flags
    # @return [Integer] 0 on success, 1 on error
    def call(flags = {})
      @flags = flags
      @routes = Chusaku::Routes.call
      @changes = []
      controllers_pattern = "app/controllers/**/*_controller.rb"

      Dir.glob(Rails.root.join(controllers_pattern)).each do |path|
        controller = %r{controllers/(.*)_controller\.rb}.match(path)[1]
        actions = @routes[controller]
        next if actions.nil?

        annotate_file(path: path, controller: controller, actions: actions.keys)
      end

      output_results
    end

    private

    # Adds annotations to the given file.
    #
    # @param path [String] Path to file
    # @param controller [String] Controller name
    # @param actions [Array<String>] List of valid actions for the controller
    # @return [void]
    def annotate_file(path:, controller:, actions:)
      parsed_file = Chusaku::Parser.call(path: path, actions: actions)
      parsed_file[:groups].each_cons(2) do |prev, curr|
        record_change(group: prev, type: :clean, path: path)
        next unless curr[:type] == :action

        route_data = @routes[controller][curr[:action]]
        next unless route_data.any?

        record_change(group: curr, type: :annotate, route_data: route_data, path: path)
      end

      write_to_file(path: path, parsed_file: parsed_file)
    end

    # Clean or annotate a group and track the group as changed if applicable.
    #
    # @param group [Hash] { type => Symbol, body => String }
    # @param type [Symbol] [:clean, :annotate]
    # @param path [String] File path
    # @param route_data [Array<Hash>] [{
    #   verb: String,
    #   path: String,
    #   name: String }]
    # @return [void]
    def record_change(group:, type:, path:, route_data: [])
      old_body = group[:body]

      case type
      when :clean
        clean_group(group)
      when :annotate
        annotate_group(group: group, route_data: route_data)
      end
      return if old_body == group[:body]

      @changes.push \
        old_body: old_body,
        new_body: group[:body],
        path: path,
        line_number: group[:line_number]
    end

    # Given a parsed group, clean out its contents.
    #
    # @param group [Hash] { type => Symbol, body => String }
    # @return {void}
    def clean_group(group)
      return unless group[:type] == :comment

      group[:body] = group[:body].gsub(/^\s*#\s*@route.*$\n/, "")
      group[:body] =
        group[:body].gsub(%r{^\s*# (GET|POST|PATCH/PUT|DELETE) /\S+$\n}, "")
    end

    # Add an annotation to the given group given by Chusaku::Parser that looks
    # like:
    #
    #   @route GET /waterlilies/:id (waterlilies)
    #
    # @param group [Hash] Parsed content given by Chusaku::Parser
    # @param route_data [Hash] Individual route data given by Chusaku::Routes
    # @return [void]
    def annotate_group(group:, route_data:)
      whitespace = /^(\s*).*$/.match(group[:body])[1]
      route_data.reverse_each do |datum|
        comment = "#{whitespace}# #{annotate_route(**datum)}\n"
        group[:body] = comment + group[:body]
      end
    end

    # Generate route annotation.
    #
    # @param verb [String] HTTP verb for route
    # @param path [String] Rails path for route
    # @param name [String] Name used in route helpers
    # @param defaults [Hash] Default parameters for route
    # @return [String] "@route <verb> <path> {<defaults>} (<name>)"
    def annotate_route(verb:, path:, name:, defaults:)
      annotation = "@route #{verb} #{path}"
      if defaults&.any?
        defaults_str =
          defaults
            .map { |key, value| "#{key}: #{value.inspect}" }
            .join(", ")
        annotation += " {#{defaults_str}}"
      end
      annotation += " (#{name})" unless name.nil?
      annotation
    end

    # Write annotated content to a file if it differs from the original.
    #
    # @param path [String] File path to write to
    # @param parsed_file [Hash] Hash mutated by {#annotate_group}
    # @return [void]
    def write_to_file(path:, parsed_file:)
      new_content = new_content_for(parsed_file)
      return if parsed_file[:content] == new_content

      !@flags.include?(:dry) && perform_write(path: path, content: new_content)
    end

    # Extracts the new file content for the given parsed file.
    #
    # @param parsed_file [Hash] { groups => Array<Hash> }
    # @return [String] New file content
    def new_content_for(parsed_file)
      parsed_file[:groups].map { |pf| pf[:body] }.join
    end

    # Wraps the write operation. Needed to clearly distinguish whether it's a
    # write in the test suite or a write in actual use.
    #
    # @param path [String] File path
    # @param content [String] File content
    # @return [void]
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
    # @return [String] 'r' or 'w'
    def file_mode
      File.instance_methods.include?(:test_write) ? "r" : "w"
    end

    # Output results to user.
    #
    # @return [Integer] 0 for success, 1 for error
    def output_results
      puts(output_copy)
      exit_code = 0
      exit_code = 1 if @changes.any? && @flags.include?(:error_on_annotation)
      exit_code
    end

    # Determines the copy to be used in the program output.
    #
    # @return [String] Copy to be outputted to user
    def output_copy
      return "Nothing to annotate." if @changes.empty?

      copy = changes_copy
      copy += "\nChusaku has finished running."
      copy += "\nThis was a dry run so no files were changed." if @flags.include?(:dry)
      copy += "\nExited with status code 1." if @flags.include?(:error_on_annotation)
      copy
    end

    # Returns the copy for recorded changes if `--verbose` flag is passed.
    #
    # @return [String] Copy of recorded changes
    def changes_copy
      return "" unless @flags.include?(:verbose)

      @changes.map do |change|
        <<~CHANGE_OUTPUT
          [#{change[:path]}:#{change[:line_number]}]

          Before:
          ```ruby
          #{change[:old_body].chomp}
          ```

          After:
          ```ruby
          #{change[:new_body].chomp}
          ```
        CHANGE_OUTPUT
      end.join("\n")
    end
  end
end
