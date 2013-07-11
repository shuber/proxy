module Proxy
  module ActionDispatch
    module Request
      def self.included(base)
        base.class_eval do
          mattr_accessor :forwarded_uri_header_name
          self.forwarded_uri_header_name = 'HTTP_X_FORWARDED_URI'
          memoize :forwarded_hosts, :forwarded_uris if respond_to? :memoize
        end
      end

      # Parses the forwarded host header and returns an array of forwarded hosts
      #
      # For example:
      #
      #   If the HTTP_X_FORWARDED_HOST header was set to
      #     'some-domain.com, some-other-domain.com, and-another-domain.com'
      #
      # This method would return ['some-domain.com', 'some-other-domain.com', 'and-another-domain.com']
      #
      # Returns an empty array if there aren't any forwarded hosts
      def forwarded_hosts
        hosts = env['HTTP_X_FORWARDED_HOST'].to_s.split(/,\s*/)
        unless hosts.empty? || hosts.first != hosts.last
          hosts << env['HTTP_HOST'] unless env['HTTP_HOST'].blank?
          env['HTTP_X_FORWARDED_HOST'] = hosts.join(', ')
        end
        hosts
      end

      # Parses the forwarded uri header and returns an array of forwarded uris
      #
      # For example:
      #
      #   If the HTTP_X_FORWARDED_URI header was set to
      #     '/some/path, /some/other/path, /and/another/path'
      #
      # This method would return ['/some/path, '/some/other/path', '/and/another/path']
      #
      # Returns an empty array if there aren't any forwarded uris
      def forwarded_uris
        env[self.forwarded_uri_header_name].to_s.split(/,\s*/)
      end
    end
  end
end
