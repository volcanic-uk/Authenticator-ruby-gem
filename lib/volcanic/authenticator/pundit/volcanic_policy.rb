# frozen_string_literal: true

module Volcanic::Authenticator::Pundit
  # Set everything to false, we'll overwrite these later.
  class VolcanicPolicy
    attr_reader :user, :token, :record

    def initialize(user_context, record)
      @user = user_context.user
      @token = user_context.token
      @record = record
    end

    def index?
      false
    end

    def show?
      false
    end

    def create?
      false
    end

    def new?
      create?
    end

    def update?
      false
    end

    def edit?
      update?
    end

    def destroy?
      false
    end

    # AR based queries, we won't use for now but will be very
    # useful when we have direct access to the DB.
    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope
      end
    end
  end
end
