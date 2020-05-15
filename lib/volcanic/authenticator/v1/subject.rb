# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Subject api
    class Subject < Common
      class << self
        def path
          'api/v1/subject'
        end

        def exception
          SubjectError
        end

        # Gets a list of permissions back from the AuthService
        # Create Permission objects, in memory
        # Create Privilege objects, referencing the Permission object
        # Return an array of Privilege objects
        # Filtering by service, a single hash is returned.
        def privileges_for(subject, service)
          response = perform_get_and_parse(
            exception,
            "#{path}/privileges?filter[subject]=#{subject}&filter[service]=#{service}"
          )
          return [] if response.blank?

          privileges = []
          response['permissions'].each do |perm|
            perm.fetch('privileges', []).each do |priv|
              privileges << Privilege.new(scope: priv['scope'],
                                          allow: priv['allow'],
                                          id: priv['id'],
                                          permission_id: perm['id'])
            end
          end
          privileges
        end
      end
    end
  end
end
