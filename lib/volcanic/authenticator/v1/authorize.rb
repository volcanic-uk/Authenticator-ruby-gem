# frozen_string_literal: true

require_relative 'helper/request'
require_relative 'helper/error'

module Volcanic::Authenticator
  module V1
    # authorise method
    class Authorize
      include Request
      include Error

      URL = 'api/v1/privileges'

      def authorize_method(subject, service, permission, action, resource_id = '*')
        # get privileges
        end_point = [service, "#{permission}:#{action}"].join('/')
        url = "#{URL}/#{end_point}?fullyQualifiedSubject=#{subject}"
        exception = :raise_exception_privilege
        privileges = perform_get_and_parse(exception, url)
        allow?(privileges, subject, permission, resource_id)
      end

      def allow?(privileges, subject, permission, id)
        return false if privileges.nil?

        return privileges.first['allow'] if privileges.count == 1

        temp_allow = false
        subject = subject.split('/')
        privileges.each do |p|
          scope = p['scope'].split(':')
          stack = scope[1]
          dataset_id = scope[2]
          resource = scope.last.split('/')

          # check for accurate stack
          next unless ['*', subject[2]].include?(stack)

          # check for accurate dataset_id
          next unless ['*', subject[3]].include?(dataset_id)

          # check for accurate permission/resource type
          next unless permission == resource.first

          # check for accurate resource id
          next unless ['*', id].include?(resource.last)

          temp_allow = p['allow']
          break unless temp_allow
        end

        temp_allow
      end
    end
  end
end
