# frozen_string_literal: true

require 'optparse'
require 'chusaku'

module Chusaku
  # Enables flags for the `chusaku` executable.
  class CLI
    attr_reader :options

    STATUS_SUCCESS = 0
    STATUS_ERROR = 1

    Finished = Class.new(RuntimeError)
    NotARailsProject = Class.new(RuntimeError)

    # Initializes a new instance of Chusaku::CLI.
    #
    # @return {Chusaku::CLI} - Instance of this class
    def initialize
      @options = {}
    end

    # Parse CLI flags, if any, and handle applicable behaviors.
    #
    # @param {Array<String>} args - CLI arguments
    # @return {Integer} - 0 on success, 1 on error
    def call(args = ARGV)
      optparser.parse!(args)
      check_for_rails_project
      Chusaku.call(options)
    rescue NotARailsProject
      warn('Please run chusaku from the root of your project.')
      STATUS_ERROR
    rescue Finished
      STATUS_SUCCESS
    end

    private

    # Raises exception if Rails project cannot be detected.
    #
    # @raise {Chusaku::CLI::NotARailsProject} - Exception if not Rails project
    # @return {void}
    def check_for_rails_project
      has_controllers = File.directory?('./app/controllers')
      has_rakefile = File.exist?('./Rakefile')
      raise NotARailsProject unless has_controllers && has_rakefile
    end

    # Returns an instance of OptionParser with supported flags.
    #
    # @return {OptionParser} - Preconfigured OptionParser instance
    def optparser
      OptionParser.new do |opts|
        opts.banner = 'Usage: chusaku [options]'
        add_error_on_annotation_flag(opts)
        add_dry_run_flag(opts)
        add_version_flag(opts)
        add_help_flag(opts)
      end
    end

    # Adds `--exit-with-error-on-annotation` flag.
    #
    # @param {OptionParser} opts - OptionParser instance
    # @return {void}
    def add_error_on_annotation_flag(opts)
      opts.on(
        '--exit-with-error-on-annotation',
        'Fail if any file was annotated'
      ) do
        @options[:error_on_annotation] = true
      end
    end

    # Adds `--dry-run` flag.
    #
    # @param {OptionParser} opts - OptionParser instance
    # @return {void}
    def add_dry_run_flag(opts)
      opts.on(
        '--dry-run',
        'Run without file modifications'
      ) do
        @options[:dry] = true
      end
    end

    # Adds `--version` flag.
    #
    # @param {OptionParser} opts - OptionParser instance
    # @return {void}
    def add_version_flag(opts)
      opts.on(
        '-v',
        '--version',
        'Show Chusaku version number and quit'
      ) do
        puts(Chusaku::VERSION)
        raise Finished
      end
    end

    # Adds `--help` flag.
    #
    # @param {OptionParser} opts - OptionParser instance
    # @return {void}
    def add_help_flag(opts)
      opts.on(
        '-h',
        '--help',
        'Show this help message and quit'
      ) do
        puts(opts)
        raise Finished
      end
    end
  end
end
