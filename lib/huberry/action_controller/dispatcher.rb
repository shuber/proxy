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
        ::ActionController::UrlRewriter.default_url_options[:host] = @original_default_host
      end
      
      def set_default_host
        @original_default_host = ::ActionController::UrlRewriter.default_url_options[:host].to_s
        ::ActionController::UrlRewriter.default_url_options[:host] = @request.env['HTTP_X_FORWARDED_HOST'].blank? ? @request.host.to_s : @request.env['HTTP_X_FORWARDED_HOST'].split(',').first
      end
      
      def set_session_domain
        ::ActionController.session_options.merge!(:session_domain => ".#{$1}") if /([^\.]+\.[^\.]+)$/.match(::ActionController::UrlRewriter.default_url_options[:host])
      end
    end
  end
end