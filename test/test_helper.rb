# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'mock/rails'
require 'mock/file'
require 'chusaku/parser'
require 'chusaku/routes'
require 'chusaku'
require 'minitest/autorun'
