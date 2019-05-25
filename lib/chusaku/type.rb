# frozen_string_literal: true

module Chusaku
  module Type
    # Given a string, returns its type:
    #
    #   1. comment - A line that is entirely commented. Lines that have trailing
    #                comments do not fall under this category.
    #   2. def     - A line that contians a method definition
    #   3. code    - Anything else.
    #
    # @param {String} line
    # @return {Symbol}
    def self.call(line)
      if !/^(\s*)#.*$/.match(line).nil?
        :comment
      elsif !/^(\s*)def\s+(\w*).*$/.match(line).nil?
        :def
      else
        :code
      end
    end
  end
end
