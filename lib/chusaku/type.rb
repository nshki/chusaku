# frozen_string_literal: true

module Chusaku
  module Type
    # Given a line and an action, returns the line's type:
    #
    #   1. comment - A line that is entirely commented. Lines that have trailing
    #                comments do not fall under this category.
    #   2. action  - A line that contains the action definition.
    #   3. code    - Anything else.
    #
    # @param {String} line
    # @param {String} action
    # @return {Symbol}
    def self.call(line:, action:)
      if !/^(\s*)#.*$/.match(line).nil?
        :comment
      elsif !/^(\s*)def\s+#{action}\s*(\w*).*$/.match(line).nil?
        :action
      else
        :code
      end
    end
  end
end
