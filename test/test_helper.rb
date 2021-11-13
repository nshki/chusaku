$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require_relative "mock/rails"
require_relative "mock/file"
require "chusaku/cli"
require "minitest/autorun"

module ChusakuTestPlugin
  def before_setup
    super

    File.reset_mock
    Rails.set_route_allowlist([])
  end
end

class Minitest::Test
  include ChusakuTestPlugin
end
