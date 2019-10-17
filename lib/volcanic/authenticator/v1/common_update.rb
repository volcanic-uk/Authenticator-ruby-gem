# frozen_string_literal: true

require_relative 'helper/request'
require_relative 'helper/error'
require_relative 'common'

module Volcanic::Authenticator
  module V1
    # extend this class only for updating roles and privileges.
    # for now only Principal and Identity support this.
    class CommonUpdate < Common
      def update_role_ids(*ids)
        payload = { roles: ids.flatten.compact }
        path = [self.class.path, "/#{id}/roles"].join
        request_to_update path, payload
        self.role_ids = ids.flatten.compact.map!(&:to_i)
      end

      def update_privilege_ids(*ids)
        payload = { privileges: ids.flatten.compact }
        path = [self.class.path, "/#{id}/privileges"].join
        request_to_update path, payload
        self.privilege_ids = ids.flatten.compact.map!(&:to_i)
      end

      private

      def request_to_update(path, payload)
        perform_post_and_parse self.class::EXCEPTION, path, payload.to_json
      end
    end
  end
end
