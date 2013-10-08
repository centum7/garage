module Garage
  module Meta
    class ResourcesController < Garage::ApplicationController
      include Garage::RestfulActions
      include Garage::ControllerHelper

      self.resource_class = Garage::Docs::Document

      def current_resource_owner
        nil
      end

      private

      def require_resources
        @resources = Garage::Docs::Document.all
      end
    end
  end
end
