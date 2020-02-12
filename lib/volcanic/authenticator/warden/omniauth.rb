# frozen_string_literal: true

require 'warden'
require_relative 'strategy_helper'

module Volcanic::Authenticator::Warden
  class Omniauth < Warden::Strategies::Base
    include StrategyHelper

    def omniauth
      request.env['omniauth.auth']
    end

    def valid?
      omniauth.present? && token.remote_validate
    end

    def authenticate!
      if omniauth.info.email.blank?
        fail 'no email found.'
      elsif !omniauth.info.email.match(/@volcanic.co.uk$/)
        fail 'not authorised for your domain!'
      else
        success! token
      end
    rescue Volcanic::Authenticator::V1::TokenError
      fail! invalid_message
    end

    private

    def token
      @token ||= identity.token
    end

    def identity
      return existing_identity if existing_identity?

      principal = Volcanic::Authenticator::V1::Principal.create(
        auth[:extra][:raw_info][:name], 'volcanic', role_ids, privilege_ids
      ).tap { |p| puts "PRINCIPAL: #{p.inspect}" }

      @identity ||= Volcanic::Authenticator::V1::Identity.create(
        auth[:uid], principal.id, source: auth.provider
      ).tap { |i| puts "IDENTITY: #{i.inspect}" }
    end

    def existing_identity
      @existing_identity ||= Volcanic::Authenticator::V1::Identity.find_by_name(omniauth[:uid])
    end

    def existing_identity?
      !existing_identity.id.blank?
    end
  end
end
