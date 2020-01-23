# frozen_string_literal: true

require_relative 'common'
require_relative 'permission'
require_relative 'group_permission'
require_relative 'token'

# Privilege API:
#
# 1) create new privilege
#
#   # +scope+: required 'vrn:{stack_id}:{dataset_id}:{permission}/{resource_id}'
#   # +permission+: required Permission object or id. by default nil
#   # +group_permission+: required GroupPermission object or id. by default ni
#   # +allow+: by default true. if set to false, privilege will have a deny status.
#   Privilege.create(scope, permission: nil, group_permission: nil, allow: true)
#
# 2) update privilege
#
#   # attr can be update [:scope, :permission, :group_permission, :allow]
#   prv = Privilege.new(scope)
#   prv.scope = 'vrn:sandbox:1:create/*'
#   prv.save
#
# 3) find_by_id
#
#  prv = Privilege.find_by_id(1)
#  prv.scope # => 'vrn:sandbox:1:create/*'
#
# 4) find
#
#  prvs = Privilege.find(query: 'vrn:{stack}:{dataset}:identity/*')
#  prvs # => [<Privilege: @id=1>]
#  prvs.first.id  # => 1
#  # see +Common+ class for more options
#
# 5) delete
#
#   prv = Privilege.new(id: 1)
#   prv.delete
#

module Volcanic::Authenticator
  module V1
    # Privileges api
    class Privilege < Common
      def self.path
        'api/v1/privileges'
      end

      def self.exception
        :raise_exception_privilege
      end

      attr_accessor :scope, :allow, :subject
      attr_reader :permission, :group_permission
      attr_reader :id, :subject_id, :created_at, :updated_at

      # initialize new privilege
      def initialize(id:, **opts)
        @id = id
        %i[scope subject_id allow created_at updated_at].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
        self.permission = opts[:permission] || opts[:permission_id]
        self.group_permission = opts[:group_permission] || opts[:group_id]
      end

      alias allow? allow

      def deny?
        !allow?
      end

      # update privilege
      def save
        payload = { scope: scope, permission_id: permission&.id,
                    group_id: group_permission&.id, allow: allow }
        super payload
      end

      # +perm+ can be Permission object or permission id (string)
      def permission=(perm)
        @permission =
          perm.is_a?(Permission) ? perm : (perm && Permission.new(id: perm))
      end

      # +grp_perm+ can be GroupPermission object or group id (string)
      def group_permission=(grp_perm)
        @group_permission =
          grp_perm.is_a?(GroupPermission) ? grp_perm : (grp_perm && GroupPermission.new(id: grp_perm))
      end

      # def score
      #   current_score = 0
      #   return current_score if subject.nil? || scope.nil?
      #
      #   # count score for stack
      #   current_score += 10 if ['*', subject_params[:stack]].include?(scope_params[:stack])
      #   # count score for dataset_id
      #   current_score += 30 if ['*', subject_params[:dataset_id]].include?(scope_params[:dataset_id])
      #   # count score for resource_id
      #   current_score += scope_params[:resource_id] == '*' ? 50 : 60
      #   # count score for allow/deny
      #   current_score += 1 if deny?
      #   current_score
      # end
      #
      # def <=>(other)
      #   score <=> other.score
      # end

      # private
      #
      # def subject_params
      #   # user://{stack}/{dataset_id}/{principal}/{identity}
      #   params = subject.split('/')
      #   { stack: params[2], dataset_id: params[3], principal: params[4], identity: params[5] }
      # end
      #
      # def scope_params
      #   # vrn:{stack}:{dataset_id}:{resource}/{resource_id}
      #   params = scope.split(':')
      #   resource = params[3].split('/')
      #   { stack: params[1], dataset_id: params[2], resource: resource.first, resource_id: resource.last }
      # end

      class << self
        # creating new privilege
        def create(scope, permission: nil, group_permission: nil, allow: true)
          perm = permission.is_a?(Permission) ? permission.id : permission
          grp_perm = group_permission.is_a?(GroupPermission) ? group_permission.id : group_permission
          payload = { scope: scope, permission_id: perm, group_id: grp_perm, allow: allow }
          super payload
        end

        # fetch privileges for given token
        # +token+: required a Token object
        # +service+: fetch for specific service. eg 'auth'
        # +permission+: fetch for specific permission. eg 'identity:create'. required structure "{model}:{action}"
        def fetch_for_token(token, service, permission)
          raise TypeError unless token.is_a? Token

          fetch_for_subject(token.sub, service, permission)
        end

        # fetch privileges for given  subject
        # +subject+: eg. 'user://{stack}/{dataset_id}/{principal}/{identity}'
        # +service+: name of a service. eg 'auth'
        # +permission+: name of permission. eg 'identity:create'. required structure "{model}:{action}"
        def fetch_for_subject(subject, service, permission)
          endpoint = [path, service, "#{permission}?subject=#{subject}"].join('/')
          res = perform_get_and_parse(exception, endpoint)
          return_privileges(res, subject)
        end

        private

        # def filter_by_service(res, service)
        #   res.find { |serv| serv['name'] == service }
        # end
        #
        # def filter_by_permission(res, permission)
        #   res['permissions'].find { |perm| perm['name'] == permission }
        # end

        def return_privileges(res, subject = nil)
          res.map do |prv|
            instance = new(prv.transform_keys(&:to_sym))
            instance.subject = subject # is needed for sorting score
            instance
          end
        end
      end
    end
  end
end
