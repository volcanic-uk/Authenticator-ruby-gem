# frozen_string_literal: true

require_relative 'lib/volcanic/authenticator/version'

Gem::Specification.new do |spec|
  spec.name          = 'volcanic-authenticator'
  spec.version       = Volcanic::Authenticator::VERSION
  spec.authors       = ['Faridul Azmi']
  spec.email         = ['ahmadfaridulazmi@gmail.com']

  spec.summary       = 'Ruby gem for Volcanic Authenticator'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/volcanic-uk/Authenticator-ruby-gem'
  spec.files         = Dir.glob 'lib/**/*.rb'
  spec.require_paths = %w[lib]

  spec.add_runtime_dependency 'activeresource'
  spec.add_runtime_dependency 'activeresource-response'
  spec.add_runtime_dependency 'down'
  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'jwt'
  spec.add_runtime_dependency 'omniauth'
  spec.add_runtime_dependency 'omniauth-google-oauth2'
  spec.add_runtime_dependency 'pundit'
  spec.add_runtime_dependency 'volcanic-cache'
  spec.add_runtime_dependency 'warden', '~> 1.2.3'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.3'
  spec.add_development_dependency 'rubocop', '~> 0.57.2'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
