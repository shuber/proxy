module Huberry
  module ActionController
    module Base
      def self.included(base)
        base.class_eval do
          cattr_accessor :relative_url_root
          alias_method_chain :redirect_to, :forwarded_host
          around_filter :set_relative_url_root
        end
      end
      
      def redirect_to_with_forwarded_host(options = {}, response_status = {})
        unless request.env['HTTP_X_FORWARDED_HOST'].blank?
          host = request.env['HTTP_X_FORWARDED_HOST'].split(', ').first
          if options.is_a? Hash
            options[:host] = host
          else
            request.instance_variable_set('@host_with_port', host + request.port_string)
          end
        end
        redirect_to_without_forwarded_host(options, response_status)
      end

      def set_relative_url_root
        if self.class.relative_url_root.blank?
          yield
        else
          @original_relative_url_root = ActionController::AbstractRequest.relative_url_root.to_s
          ActionController::AbstractRequest.relative_url_root = self.class.relative_url_root
          begin
            yield
          ensure
            ActionController::AbstractRequest.relative_url_root = @original_relative_url_root
          end
        end
      end
    end
  end
end