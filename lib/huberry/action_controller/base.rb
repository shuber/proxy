module Huberry
  module ActionController
    module Base
      def self.included(base)
        base.class_eval do
          cattr_accessor :original_relative_url_root
          cattr_accessor :proxy_relative_url_root
          before_filter :set_proxy_relative_url_root
          around_filter :swap_relative_url_root
          class << self; delegate :relative_url_root, :relative_url_root=, :to => ::ActionController::AbstractRequest unless respond_to? :relative_url_root; end
        end
      end

      protected
      
        def set_proxy_relative_url_root
          self.class.proxy_relative_url_root = request.forwarded_uris.first.gsub(/#{Regexp.escape(request.path)}$/, '') unless request.forwarded_uris.empty?
        end

        def swap_relative_url_root
          if self.class.proxy_relative_url_root.blank?
            yield
          else
            self.class.original_relative_url_root = self.class.relative_url_root.to_s
            self.class.relative_url_root = self.class.proxy_relative_url_root
            begin
              yield
            ensure
              self.class.relative_url_root = self.class.original_relative_url_root
            end
          end
        end
    end
  end
end