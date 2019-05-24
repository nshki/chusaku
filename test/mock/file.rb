# frozen_string_literal: true

class File
  @@written_files = []

  # Given a string, append it to a variable.
  #
  # @param {String} str
  # @return {void}
  def write(str)
    @@written_files.push(str)
  end

  # Get class variable value and clear.
  #
  # @return {Array<String>}
  def self.written_files
    written_files = @@written_files
    @@written_files = []
    written_files
  end
end
