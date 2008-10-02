module Huberry
  module ActionController
    module AbstractRequest
      def self.included(base)
        base.class_eval do
          cattr_accessor :forwarded_uri_header_name
          self.forwarded_uri_header_name = 'HTTP_X_FORWARDED_URI'
          memoize :forwarded_hosts, :forwarded_uris if respond_to? :memoize
        end
      end
      
      def forwarded_hosts
        env['HTTP_X_FORWARDED_HOST'].to_s.split(/,\s?/)
      end
      
      def forwarded_uris
        env[self.forwarded_uri_header_name].to_s.split(/,\s?/)
      end
    end
  end
end