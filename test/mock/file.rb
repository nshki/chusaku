# frozen_string_literal: true

class File
  @@written_files = {}

  # Given a file's content and path, write the content in memory rather than in
  # the actual file.
  #
  # @param {String} content - Contents of file
  # @param {String} path - File path
  # @return {void}
  def test_write(content, path)
    @@written_files[path] = content
  end

  # Get the content of files in memory.
  #
  # @return {Hash} Mapping of files to their contents
  def self.written_files
    written_files = @@written_files
    reset_mock
    written_files
  end

  # Reset in memory cache.
  #
  # @return {void}
  def self.reset_mock
    @@written_files = {}
  end
end
