# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chusaku/version'

Gem::Specification.new do |spec|
  spec.name = 'chusaku'
  spec.version = Chusaku::VERSION
  spec.authors = ['Nishiki Liu']
  spec.email = ['nishiki.liu@gmail.com']

  spec.summary = 'Annotate your Rails controllers with route info.'
  spec.description = 'Annotate your Rails controllers with route info.'
  spec.homepage = 'https://github.com/nshki/chusaku'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this section
  # to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'bin'
  spec.executables   = 'chusaku'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rubocop', '~> 0.77'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'

  spec.add_dependency 'rails', '> 2.0'
end
