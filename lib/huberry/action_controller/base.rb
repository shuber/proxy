module Huberry
  module ActionController
    module Base
      def self.included(base)
        base.class_eval do
          before_filter :set_proxy_relative_url_root
          around_filter :swap_relative_url_root
          mattr_accessor :original_relative_url_root
          mattr_accessor :proxy_relative_url_root
          class << self; delegate :relative_url_root, :relative_url_root=, :to => ::ActionController::AbstractRequest unless respond_to? :relative_url_root; end
        end
      end

      protected
      
        def set_proxy_relative_url_root
          ::ActionController::Base.proxy_relative_url_root = request.forwarded_uris.first.gsub(/#{Regexp.escape(request.path)}$/, '') unless request.forwarded_uris.empty?
        end

        def swap_relative_url_root
          if ::ActionController::Base.proxy_relative_url_root.blank?
            yield
          else
            ::ActionController::Base.original_relative_url_root = ::ActionController::Base.relative_url_root.to_s
            ::ActionController::Base.relative_url_root = ::ActionController::Base.proxy_relative_url_root
            begin
              yield
            ensure
              ::ActionController::Base.relative_url_root = ::ActionController::Base.original_relative_url_root
            end
          end
        end
    end
  end
end