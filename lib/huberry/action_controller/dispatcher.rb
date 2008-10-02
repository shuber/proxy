module Huberry
  module ActionController
    module Dispatcher
      def self.included(base)
        base.class_eval do
          before_dispatch :set_default_host
          before_dispatch :set_session_domain
          after_dispatch :restore_default_host
        end
      end
      
      def restore_default_host
        ::ActionController::UrlWriter.default_url_options[:host] = ::ActionController::UrlWriter.default_url_options[:original_host]
      end
      
      def set_default_host
        ::ActionController::UrlWriter.default_url_options[:original_host] = ::ActionController::UrlWriter.default_url_options[:host]
        ::ActionController::UrlWriter.default_url_options[:host] = @request.forwarded_hosts.first unless @request.forwarded_hosts.empty?
      end
      
      def set_session_domain
        ::ActionController.session_options.merge!(:session_domain => ".#{$1}") if /([^\.]+\.[^\.]+)$/.match(@request.forwarded_hosts.first || @request.host)
      end
    end
  end
end