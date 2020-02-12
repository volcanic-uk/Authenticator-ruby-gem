# frozen_string_literal: true

module Volcanic::Pundit
  # ApplicationPolicy
  # Base policy to inherit from
  class ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
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

    class Permission
      def initialize(action)
        @action = action
        @permissions = []
      end

      def resolve
        
      end

      attr_reader :action, :permissions
    end

    # Default scope should we wish to use this with Finders
    class Scope
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope.all
      end

      private

      attr_reader :user, :scope
    end
  end
end
