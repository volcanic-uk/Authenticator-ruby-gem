# frozen_string_literal: true

require 'warden'
require_relative 'strategy_helper'

module Volcanic::Authenticator::Warden
  # Validate omniauth information for SuperAdmin (or any omniauth) user
  class VolcanicOmniauth < Warden::Strategies::Base
    include StrategyHelper

    def omniauth
      request.env['omniauth.auth']
    end

    def valid?
      omniauth.present? && token.remote_validate
    end

    def authenticate!
      fail! 'not authorised for your domain!' unless omniauth.info.email.match(/@volcanic.co.uk$/)
      success! token if token_valid?
      fail! invalid_message
    rescue Volcanic::Authenticator::V1::TokenError
      fail! invalid_message
    end

    private

    def token
      @token ||= identity.token
    end

    def identity
      return existing_identity if existing_identity?

      @identity ||= Volcanic::Authenticator::V1::Identity.create(
        auth[:uid], principal.id, source: auth.provider
      )
    end

    def principal
      @principal ||= Volcanic::Authenticator::V1::Principal.create(
        auth[:extra][:raw_info][:name], 'volcanic', role_ids, privilege_ids
      )
    end

    def existing_identity
      @existing_identity ||= Volcanic::Authenticator::V1::Identity.find_by_name(omniauth[:uid])
    end

    def existing_identity?
      !existing_identity.id.blank?
    end
  end
end
