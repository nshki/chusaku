# frozen_string_literal: true

require 'optparse'
require 'chusaku'

module Chusaku
  class CLI
    STATUS_SUCCESS = 0
    STATUS_ERROR = 1

    attr_reader :options

    Finished = Class.new(RuntimeError)
    NotARailsProject = Class.new(RuntimeError)

    def initialize
      @options = {}
    end

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

    def check_for_rails_project
      unless File.directory?('./app/controllers') && File.exist?('./Rakefile')
        raise NotARailsProject
      end
    end

    def optparser
      OptionParser.new do |opts|
        opts.banner = 'Usage: chusaku [options]'
        opts.on('--exit-with-error-on-annotation', 'Fail if any file was annotated') do |arg|
          @options[:error_on_annotation] = true
        end
        opts.on('--dry-run', 'Run without file modifications') do |arg|
          @options[:dry] = true
        end
        opts.on('-v', '--version', 'Show Chusaku version number and quit') do |arg|
          puts(Chusaku::VERSION)
          raise Finished
        end
        opts.on('-h', '--help', 'Show this help message and quit') do
          puts(opts)
          raise Finished
        end
      end
    end
  end
end
