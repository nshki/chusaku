# frozen_string_literal: true

class File
  @@written_files = {}

  # Given a string, append it to a variable.
  #
  # @param {String} str
  # @param {String} path
  # @return {void}
  def test_write(str, path)
    @@written_files[path] = str
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
