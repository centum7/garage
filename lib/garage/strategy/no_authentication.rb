module Garage
  module Strategy
    module NoAuthentication
      def access_token
        nil
      end

      def verify_permission?
        false
      end
    end
  end
end
