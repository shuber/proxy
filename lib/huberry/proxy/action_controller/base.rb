module Huberry
  module Proxy
    module ActionController
      module Base
        def self.included(base)
          base.class_eval do
            before_filter :set_proxy_relative_url_root
            around_filter :swap_default_host
            around_filter :swap_relative_url_root
            around_filter :swap_session_domain
            cattr_accessor :original_relative_url_root
            cattr_accessor :proxy_relative_url_root
            alias_method_chain :redirect_to, :proxy
            class << self; delegate :relative_url_root, :relative_url_root=, :to => ::ActionController::AbstractRequest unless ::ActionController::Base.respond_to?(:relative_url_root); end
          end
        end

        protected
      
          # Calculates the <tt>relative_url_root</tt> by parsing the request path out of the
          # first forwarded uri
          #
          # For example:
          #
          #   http://example.com/manage/videos/new
          #     gets proxied to
          #   http://your-domain.com/videos/new
          #
          # The first forwarded uri would be: /manage/videos/new
          # and the request path would be:    /videos/new
          #
          # So this method would return: /manage
          def parse_proxy_relative_url_root
            request.forwarded_uris.first.gsub(/#{Regexp.escape(request.path)}$/, '')
          end
        
          # Calculates the <tt>session_domain</tt> by parsing the first domain.tld out of the
          # first forwarded host and prepending a '.'
          #
          # For example:
          #
          #   http://example.com/manage/videos/new
          #   http://some.other-domain.com/videos/new
          #     both get proxied to
          #   http://your-domain.com/videos/new
          #
          # The resulting session domain for the first url would be: '.example.com'
          # The resulting session domain for the second url would be: '.other-domain.com'
          def parse_session_domain
            ".#{$1}" if /([^\.]+\.[^\.]+)$/.match(request.forwarded_hosts.first)
          end
        
          # Forces redirects to use the <tt>default_url_options[:host]</tt> if it exists unless a host
          # is already set
          #
          # For example:
          #
          #   http://example.com
          #     gets proxied to
          #   http://your-domain.com
          #
          # If you have an action that calls <tt>redirect_to new_videos_path</tt>, the example.com domain
          # would be used instead of your-domain.com
          def redirect_to_with_proxy(*args)
            args[0] = request.protocol + ::ActionController::UrlWriter.default_url_options[:host] + args.first if args.first.is_a?(String) && !%r{^\w+://.*}.match(args.first) && !::ActionController::UrlWriter.default_url_options[:host].blank?
            redirect_to_without_proxy(*args)
          end
      
          # Sets the <tt>proxy_relative_url_root</tt> using the +parse_proxy_relative_url_root+ method
          # to calculate it
          #
          # Sets the <tt>proxy_relative_url_root</tt> to nil if there aren't any forwarded uris
          def set_proxy_relative_url_root
            ::ActionController::Base.proxy_relative_url_root = request.forwarded_uris.empty? ? nil : parse_proxy_relative_url_root
          end
        
          # Sets the <tt>default_url_options[:host]</tt> to the first forwarded host if there are any
          #
          # The original default host is restored after each request and can be accessed by calling
          #   <tt>ActionController::UrlWriter.default_url_options[:original_host]</tt>
          def swap_default_host
            ::ActionController::UrlWriter.default_url_options[:original_host] = ::ActionController::UrlWriter.default_url_options[:host]
            ::ActionController::UrlWriter.default_url_options[:host] = request.forwarded_hosts.first unless request.forwarded_hosts.empty?
            begin
              yield
            ensure
              ::ActionController::UrlWriter.default_url_options[:host] = ::ActionController::UrlWriter.default_url_options[:original_host]
            end
          end
        
          # Sets the <tt>relative_url_root</tt> to the <tt>proxy_relative_url_root</tt> unless it's nil
          #
          # The original relative url root is restored after each request and can be accessed by calling
          #   <tt>ActionController::Base.original_relative_url_root</tt>
          def swap_relative_url_root
            ::ActionController::Base.original_relative_url_root = ::ActionController::Base.relative_url_root
            ::ActionController::Base.relative_url_root = ::ActionController::Base.proxy_relative_url_root unless ::ActionController::Base.proxy_relative_url_root.nil?
            begin
              yield
            ensure
              ::ActionController::Base.relative_url_root = ::ActionController::Base.original_relative_url_root
            end
          end
        
          # Sets the <tt>session_options[:session_domain]</tt> to the result of the +parse_session_domain+ method
          # unless there aren't any forwarded hosts
          #
          # The original session domain is restored after each request and can be accessed by calling
          #   <tt>ActionController::Base.session_options[:original_session_domain]</tt>
          def swap_session_domain
            ::ActionController::Base.session_options[:original_session_domain] = ::ActionController::Base.session_options[:session_domain]
            ::ActionController::Base.session_options[:session_domain] = parse_session_domain unless request.forwarded_hosts.empty?
            begin
              yield
            ensure
              ::ActionController::Base.session_options[:session_domain] = ::ActionController::Base.session_options[:original_session_domain]
            end
          end
      end
    end
  end
end