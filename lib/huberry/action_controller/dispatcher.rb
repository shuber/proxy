module Huberry
  module ActionController
    module Dispatcher
      def self.included(base)
        base.send :before_dispatch, :set_session_domain
      end
      
      def set_session_domain
        host = @request.env['HTTP_X_FORWARDED_HOST'].blank? ? @request.host : @request.env['HTTP_X_FORWARDED_HOST'].split(', ').first
        ApplicationController.session_options.merge!(:session_domain => ".#{$1}") if /([^\.]+\.[^\.]+)$/.match(host)
      end 
    end
  end
end