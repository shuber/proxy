module Huberry
  module ActionController
    module Base
      def self.included(base)
        base.class_eval do
          before_filter :set_session_domain
          before_filter :set_proxy_relative_url_root
          around_filter :swap_default_host
          around_filter :swap_relative_url_root
          mattr_accessor :original_relative_url_root
          mattr_accessor :proxy_relative_url_root
          class << self; delegate :relative_url_root, :relative_url_root=, :to => ::ActionController::AbstractRequest unless ::ActionController::Base.respond_to? :relative_url_root; end
        end
      end

      protected
      
        def set_proxy_relative_url_root
          ::ActionController::Base.proxy_relative_url_root = request.forwarded_uris.empty? ? nil : request.forwarded_uris.first.gsub(/#{Regexp.escape(request.path)}$/, '')
        end
        
        def set_session_domain
          ::ActionController::Base.session_options.merge!(:session_domain => ".#{$1}") if /([^\.]+\.[^\.]+)$/.match(request.forwarded_hosts.first || request.host)
        end
        
        def swap_default_host
          ::ActionController::UrlWriter.default_url_options[:original_host] = ::ActionController::UrlWriter.default_url_options[:host]
          ::ActionController::UrlWriter.default_url_options[:host] = request.forwarded_hosts.first unless request.forwarded_hosts.empty?
          begin
            yield
          ensure
            ::ActionController::UrlWriter.default_url_options[:host] = ::ActionController::UrlWriter.default_url_options[:original_host]
          end
        end
        
        def swap_relative_url_root
          ::ActionController::Base.original_relative_url_root = ::ActionController::Base.relative_url_root
          ::ActionController::Base.relative_url_root = ::ActionController::Base.proxy_relative_url_root unless ::ActionController::Base.proxy_relative_url_root.nil?
          begin
            yield
          ensure
            ::ActionController::Base.relative_url_root = ::ActionController::Base.original_relative_url_root
          end
        end
    end
  end
end