# frozen_string_literal: true

module Chusaku
  module Type
    # Given a line and actions, returns the line's type:
    #
    #   1. comment - A line that is entirely commented. Lines that have trailing
    #                comments do not fall under this category.
    #   2. action  - A line that contains an action definition.
    #   3. code    - Anything else.
    #
    # @param {String} line
    # @param {Array<String>} actions
    # @return {Symbol}
    def self.call(line:, actions:)
      comment_match = /^\s*#.*$/.match(line)
      def_match = /^\s*def\s+(\w*)\s*\w*.*$/.match(line)

      if !comment_match.nil?
        :comment
      elsif !def_match.nil? && actions.include?(def_match[1])
        :action
      else
        :code
      end
    end
  end
end
