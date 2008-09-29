module Huberry
  module ActionController
    module Base
      def self.included(base)
        base.class_eval do
          cattr_accessor :forwarded_uri_variable_name
          cattr_accessor :relative_url_root
          before_filter :set_class_relative_url_root
          around_filter :set_relative_url_root
          self.forwarded_uri_variable_name = 'HTTP_X_FORWARDED_URI'
        end
      end

      protected
      
        def set_class_relative_url_root
          self.relative_url_root = request.env[self.class.forwarded_uri_variable_name].split(',').first.gsub(/#{Regexp.escape(request.env['PATH_INFO'])}$/, '') unless request.env[self.class.forwarded_uri_variable_name].blank?
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