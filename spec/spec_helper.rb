require 'bundler/setup'
require 'rspec/its'
require 'volcanic/authenticator'
require 'volcanic/cache'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Configuration
  ##
  # This value need to configure to run these test.
  def self.set
    Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3003'
    Volcanic::Authenticator.config.app_name = 'volcanic'
    Volcanic::Authenticator.config.app_secret = 'volcanic!123'
  end

  def self.reset
    Volcanic::Authenticator.config.auth_url = nil
    Volcanic::Authenticator.config.app_name = nil
    Volcanic::Authenticator.config.app_secret = nil
  end
end