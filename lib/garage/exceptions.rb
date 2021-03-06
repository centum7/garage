module Garage
  class HTTPError < ::StandardError
    attr_accessor :status
    def status_code
      Rack::Utils.status_code(status)
    end
  end

  class BadRequest < HTTPError
    def initialize(error)
      @status = :bad_request
      super(error)
    end
  end

  class Unauthorized < HTTPError
    attr_reader :user, :action, :resource_class, :scopes

    def initialize(user, action, resource_class, status = :forbidden, scopes = [])
      @user, @action, @resource_class, @status, @scopes = user, action, resource_class, status, scopes

      if scopes.empty?
        super "Authorized user is not allowed to take the requested operation #{action} on #{resource_class}"
      else
        super "Insufficient scope to process the requested operation. Missing scope(s): #{scopes.join(", ")}"
      end
    end
  end

  class PermissionError < Unauthorized; end
  class MissingScopeError < Unauthorized; end
end
