module Huberry
  module ActionController
    module AbstractRequest
      def self.included(base)
        base.class_eval do
          mattr_accessor :forwarded_uri_header_name
          self.forwarded_uri_header_name = 'HTTP_X_FORWARDED_URI'
          memoize :forwarded_hosts, :forwarded_uris if respond_to? :memoize
        end
      end
      
      # Parses and returns an array of forwarded hosts
      def forwarded_hosts
        env['HTTP_X_FORWARDED_HOST'].to_s.split(/,\s*/)
      end
      
      # Parses and returns an array of forwarded uris
      def forwarded_uris
        env[self.forwarded_uri_header_name].to_s.split(/,\s*/)
      end
    end
  end
end