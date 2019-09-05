# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require_relative 'lib/volcanic/authenticator/version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'volcanic-authenticator'
  spec.version       = '0.0.1'
  spec.authors       = ['Faridul Azmi']
  spec.email         = ['ahmadfaridulazmi@gmail.com']

  spec.summary       = 'Ruby gem for Volcanic authenticator'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/volcanic-uk/Authenticator-ruby-gem'

  all_files = `git ls-files`.split("\n")
  test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  spec.files         = all_files - test_files
  spec.test_files    = test_files
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activeresource'
  spec.add_runtime_dependency 'activeresource-response'
  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'jwt'
  spec.add_runtime_dependency 'volcanic-cache'
  spec.add_development_dependency 'bundler', '~> 2.0.2'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.3'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
