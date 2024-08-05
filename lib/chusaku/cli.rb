require "optparse"
require "chusaku"

module Chusaku
  # Enables flags for the `chusaku` executable.
  class CLI
    attr_reader :options

    STATUS_SUCCESS = 0
    STATUS_ERROR = 1

    Finished = Class.new(RuntimeError)
    NotARailsProject = Class.new(RuntimeError)

    # Initializes a new instance of `Chusaku::CLI`.
    #
    # @return [Chusaku::CLI] Instance of this class
    def initialize
      @options = {}
    end

    # Parse CLI flags, if any, and handle applicable behaviors.
    #
    # @param args [Array<String>] CLI arguments
    # @return [Integer] 0 on success, 1 on error
    def call(args = ARGV)
      optparser.parse!(args)
      check_for_rails_project
      Chusaku.call(options)
    rescue NotARailsProject
      warn("Please run chusaku from the root of your project.")
      STATUS_ERROR
    rescue Finished
      STATUS_SUCCESS
    end

    private

    # Raises exception if Rails project cannot be detected.
    #
    # @raise [Chusaku::CLI::NotARailsProject] Exception if not Rails project
    # @return [void]
    def check_for_rails_project
      controllers_pattern = options[:controllers_pattern] || DEFAULT_CONTROLLERS_PATTERN
      has_controllers = !Dir.glob(Rails.root.join(controllers_pattern)).empty?
      has_rakefile = File.exist?("./Rakefile")
      raise NotARailsProject unless has_controllers && has_rakefile
    end

    # Returns an instance of OptionParser with supported flags.
    #
    # @return [OptionParser] Preconfigured OptionParser instance
    def optparser
      OptionParser.new do |opts|
        opts.banner = "Usage: chusaku [options]"
        opts.set_summary_width(35)
        add_dry_run_flag(opts)
        add_error_on_annotation_flag(opts)
        add_controllers_pattern_flag(opts)
        add_verbose_flag(opts)
        add_version_flag(opts)
        add_help_flag(opts)
      end
    end

    # Adds `--dry-run` flag.
    #
    # @param opts [OptionParser] OptionParser instance
    # @return [void]
    def add_dry_run_flag(opts)
      opts.on("--dry-run", "Run without file modifications") do
        @options[:dry] = true
      end
    end

    # Adds `--exit-with-error-on-annotation` flag.
    #
    # @param opts [OptionParser] OptionParser instance
    # @return [void]
    def add_error_on_annotation_flag(opts)
      opts.on("--exit-with-error-on-annotation", "Fail if any file was annotated") do
        @options[:error_on_annotation] = true
      end
    end

    # Adds `--controllers-pattern` flag.
    #
    # @param opts [OptionParser] OptionParser instance
    # @return [void]
    def add_controllers_pattern_flag(opts)
      opts.on("-c", "--controllers-pattern", "=GLOB", "Specify alternative controller files glob pattern") do |value|
        @options[:controllers_pattern] = value
      end
    end

    # Adds `--verbose` flag.
    #
    # @param opts [OptionParser] OptionParser instance
    # @return [void]
    def add_verbose_flag(opts)
      opts.on("--verbose", "Print all annotated files") do
        @options[:verbose] = true
      end
    end

    # Adds `--version` flag.
    #
    # @param opts [OptionParser] OptionParser instance
    # @return [void]
    def add_version_flag(opts)
      opts.on("-v", "--version", "Show Chusaku version number and quit") do
        puts(Chusaku::VERSION)
        raise Finished
      end
    end

    # Adds `--help` flag.
    #
    # @param opts [OptionParser] OptionParser instance
    # @return [void]
    def add_help_flag(opts)
      opts.on("-h", "--help", "Show this help message and quit") do
        puts(opts)
        raise Finished
      end
    end
  end
end
