module Huberry
  module ActionView
    module UrlHelper
      def self.included(base)
        base.class_eval { alias_method_chain :url_for, :proxy }
      end
      
      # We have to pass the :host option or url_for assumes you only want the path
      def url_for_with_proxy(options = {})
        options[:host] ||= ::ActionController::UrlWriter.default_url_options[:host] unless ::ActionController::UrlWriter.default_url_options[:host].blank?
        url_for_without_proxy(options)
      end
    end
  end
end