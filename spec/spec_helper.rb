# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/its'
require 'volcanic/authenticator'
require 'volcanic/cache'
require 'vcr'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Volcanic::Authenticator::Authorization::UserPrivilegeCache._reset_instance
  end
end

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
end

module Configuration
  # configure setting
  def self.set
    Volcanic::Authenticator.config.auth_url = 'http://localhost:6000'
    Volcanic::Authenticator.config.app_name = 'volcanic'
    Volcanic::Authenticator.config.app_secret = 'volcanic!123'
    Volcanic::Authenticator.config.app_dataset_id = '-1'
    Volcanic::Authenticator.config.service_name = 'auth'
  end

  # reset setting
  def self.reset
    Volcanic::Authenticator.config.auth_url = nil
    Volcanic::Authenticator.config.app_name = nil
    Volcanic::Authenticator.config.app_secret = nil
  end

  def self.mock_tokens
    File.read('spec/mock_tokens.json')
  end

  def self.set_authorize_identity
    Volcanic::Authenticator.config.app_name = 'unauthorise'
    Volcanic::Authenticator.config.app_secret = 'secret'
    Volcanic::Authenticator.config.app_dataset_id = '90'
  end
end
