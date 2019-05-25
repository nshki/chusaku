# frozen_string_literal: true

module Chusaku
  module Parser
    # Parses a file and groups its lines into categories:
    #
    # Example output:
    #
    #   [ { type: :code,    body: 'class Foo\n' },
    #     { type: :comment, body: '  # Bar\n  # Baz\n' },
    #     { type: :action,  body: '  def action_name; end\n' }
    #     { type: :code,    body: 'end # vanilla is the best flavor\n' } ]
    #
    # @param {String} path
    # @param {Array<String>} actions
    # @return {Array<Hash>}
    def self.call(path:, actions:)
      groups = []
      group = {}

      File.open(path, 'r').each_line do |line|
        type = Chusaku::Type.call(line: line, actions: actions)

        if group[:type] != type
          # Now looking at a new group. Push the current group onto the array
          # and start a new one.
          groups.push(group) unless group.empty?
          group = { type: type, body: line }
        else
          # Same group. Push the current line into the current group.
          group[:body] += line
        end
      end

      # Push the last group onto the array and return.
      groups.push(group)
      groups
    end
  end
end
