module Proxy
  module ActionController
    module Base
      def self.included(base)
        base.class_eval do
          around_filter :swap_session_domain
          around_filter :swap_default_host
          alias_method_chain :redirect_to, :proxy
        end
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
          args[0] = request.protocol + url_options[:host] + args.first if args.first.is_a?(String) && !%r{^\w+://.*}.match(args.first) && !url_options[:host].blank?
          redirect_to_without_proxy(*args)
        end

        # Sets the <tt>default_url_options[:host]</tt> to the first forwarded host if there are any
        #
        # The original default host is restored after each request and can be accessed by calling
        #   <tt>ActionController::UrlWriter.default_url_options[:original_host]</tt>
        def swap_default_host
          url_options[:original_host] = url_options[:host]
          url_options[:host] = request.forwarded_hosts.first unless request.forwarded_hosts.empty?

          begin
            yield
          ensure
            url_options[:host] = url_options[:original_host]
          end
        end
        # Sets the <tt>session_options[:session_domain]</tt> to the result of the +parse_session_domain+ method
        # unless there aren't any forwarded hosts
        #
        # The original session domain is restored after each request and can be accessed by calling
        #   <tt>ActionController::Base.session_options[:original_session_domain]</tt>
        def swap_session_domain
          original = request.session_options[:session_domain] || request.session_options[:domain]

          domain = parse_session_domain unless request.forwarded_hosts.empty?
          request.session_options = {
            original_session_options: original,
            session_domain:           domain,
            domain:                   domain
          }

          begin
            yield
          ensure
            request.session_options = {
              session_domain: original,
              domain:         original
            }
          end
        end

        def url_options
          options = super.dup

          if default_options = ::Rails.application.config.action_controller.default_url_options
            options.reverse_merge!(default_options)
          end

          options
        end

    end
  end
end
