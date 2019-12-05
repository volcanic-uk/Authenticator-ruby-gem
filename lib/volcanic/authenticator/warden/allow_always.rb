# frozen_string_literal: true

module Volcanic::Authenticator::Warden
  # this strategy allow all request
  class AllowAlways < Warden::Strategies::Base
    def authenticate!
      success! ''
    end
  end
end
