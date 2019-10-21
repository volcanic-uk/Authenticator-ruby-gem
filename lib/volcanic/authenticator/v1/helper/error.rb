# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Error helper
    module Error
      # raise exception
      class RaiseException
        attr_reader :res, :status, :raw_body, :exception

        def initialize(res, exception)
          @res = res
          @status = res.code
          @raw_body = res.body
          @exception = exception
          raise_standard_error
          raise_exception
        end

        private

        def raise_exception
          raise exception, message if [400, 404, 410, 422].include?(status)

          raise_unknown_error
        end

        def raise_standard_error
          # When a requested public key does not exist in DB
          raise SignatureError, message if status == 400 && error_code == 3002
          # When token is invalid or unsuccessful login
          raise AuthorizationError, message if [401, 403].include?(status)
        end

        # raise for unknown error occurs
        def raise_unknown_error
          raise exception, message
        end

        # response body
        def body
          @body ||= begin
                      JSON.parse(raw_body)
                    rescue JSON::ParserError
                      # return this if not a json
                      {}
                    end
        end

        # error message at response body
        def message(msg = body)
          return "Authenticator service return #{status} error" unless msg.key?('message')

          msg['message']
        end

        # error code at response body
        def error_code
          return '' unless body.key?('errorCode')

          body['errorCode']
        end
      end

      # when include this module, it will extend it too
      def self.included(base)
        base.extend self
      end

      # error handler for application token
      def raise_exception_app_token(res)
        RaiseException.new(res, ApplicationTokenError)
      end

      # error handler for service
      def raise_exception_service(res)
        RaiseException.new(res, ServiceError)
      end

      # error handler for principal
      def raise_exception_principal(res)
        RaiseException.new(res, PrincipalError)
      end

      # error handler for identity
      def raise_exception_identity(res)
        RaiseException.new(res, IdentityError)
      end

      # error handler for token
      def raise_exception_token(res)
        RaiseException.new(res, TokenError)
      end

      # error handler for not_implemented_error
      def raise_not_implemented_error(method_name)
        raise NotImplementedError, "#{method_name} must be defined by child classes"
      end
    end
  end
end
