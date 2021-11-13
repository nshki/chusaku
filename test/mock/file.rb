class File
  @@written_files = {}

  # Given a file's content and path, write the content in memory rather than in
  # the actual file.
  #
  # @param content [String] Contents of file
  # @param path [String] File path
  # @return [void]
  def test_write(content, path)
    @@written_files[path] = content
  end

  class << self
    # Get the content of files in memory.
    #
    # @return [Hash] Mapping of files to their contents
    def written_files
      written_files = @@written_files
      reset_mock
      written_files
    end

    # Reset in memory cache.
    #
    # @return [void]
    def reset_mock
      @@written_files = {}
    end
  end
end
