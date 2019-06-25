# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Error helper
    module Error
      # raise exception
      class RaiseException
        attr_reader :res, :status, :body, :exception

        def initialize(res, exception)
          @res = res
          @status = res.code
          @body = JSON.parse(res.body)
          @exception = exception
          raise_exception
        end

        private

        def raise_exception
          standard_error
          raise exception, message if [400, 404, 401, 422].include?(status)
        end

        def standard_error
          raise SignatureError, message if status == 400 && error_code == 3002
          raise AuthorizationError, message if [401, 403].include?(status)
        end

        def message
          return "HTTP error #{status}" unless body.key?('message')

          body['message']
        end

        def error_code
          return '' unless body.key?('errorCode')

          body['errorCode']
        end
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
    end
  end
end
