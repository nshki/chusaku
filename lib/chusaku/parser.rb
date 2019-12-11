# frozen_string_literal: true

module Chusaku
  # Handles parsing a file and groups its lines into categories.
  module Parser
    # Example output:
    #
    #   [ { type: :code,
    #       body: 'class Foo\n',
    #       action: nil },
    #     { type: :comment,
    #       body: '  # Bar\n  # Baz\n',
    #       action: nil },
    #     { type: :action,
    #       body: '  def action_name; end\n',
    #       action: 'action_name' }
    #     { type: :code,
    #       body: 'end # vanilla is the best flavor\n',
    #       action: nil } ]
    #
    # @param {String} path - File path to parse
    # @param {Array<String>} actions - List of valid actions for this route
    # @return {Hash} Parsed groups of the file and original content
    def self.call(path:, actions:)
      groups = []
      group = {}
      content = IO.read(path)

      content.each_line do |line|
        parsed_line = parse_line(line: line, actions: actions)

        if group[:type] != parsed_line[:type]
          # Now looking at a new group. Push the current group onto the array
          # and start a new one.
          groups.push(group) unless group.empty?
          group = parsed_line
        else
          # Same group. Push the current line into the current group.
          group[:body] += line
        end
      end

      # Push the last group onto the array and return.
      groups.push(group)
      {
        content: content,
        groups: groups
      }
    end

    # Given a line and actions, returns the line's type:
    #
    #   1. comment - A line that is entirely commented. Lines that have trailing
    #                comments do not fall under this category.
    #   2. action  - A line that contains an action definition.
    #   3. code    - Anything else.
    #
    # And give back a Hash in the form:
    #
    #   { type: :action, body: 'def foo', action: 'foo' }
    #
    # @param {String} line - A line of a file
    # @param {Array<String>} actions - List of valid actions for this route
    # @return {Hash} Parsed line
    def self.parse_line(line:, actions:)
      comment_match = /^\s*#.*$/.match(line)
      def_match = /^\s*def\s+(\w*)\s*\w*.*$/.match(line)

      if !comment_match.nil?
        { type: :comment, body: line, action: nil }
      elsif !def_match.nil? && actions.include?(def_match[1])
        { type: :action, body: line, action: def_match[1] }
      else
        { type: :code, body: line, action: nil }
      end
    end
  end
end
