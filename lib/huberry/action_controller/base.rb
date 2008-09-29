module Huberry
  module ActionController
    module Base
      def self.included(base)
        base.class_eval do
          cattr_accessor :relative_url_root
          prepend_around_filter :set_relative_url_root
        end
      end

      def set_relative_url_root
        if self.class.relative_url_root.blank?
          yield
        else
          @original_relative_url_root = ::ActionController::AbstractRequest.relative_url_root.to_s
          ::ActionController::AbstractRequest.relative_url_root = self.class.relative_url_root
          begin
            yield
          ensure
            ::ActionController::AbstractRequest.relative_url_root = @original_relative_url_root
          end
        end
      end
    end
  end
end