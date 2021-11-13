# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require_relative "mock/rails"
require_relative "mock/file"
require "chusaku/cli"
require "minitest/autorun"
