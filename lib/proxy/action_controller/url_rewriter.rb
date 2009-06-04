module Proxy
  module ActionController
    module UrlRewriter
      def self.included(base)
        base.class_eval { alias_method_chain :rewrite_url, :proxy }
      end
    
      # Adds the default :host option unless already specified
      #
      # It will not set the :host option if <tt>options</tt> is not a hash or
      # if the <tt>ActionController::UrlWriter.default_url_options[:host]</tt> is blank
      def rewrite_url_with_proxy(options)
        if options.is_a?(Hash)
          options[:host] ||= ::ActionController::UrlWriter.default_url_options[:host] unless ::ActionController::UrlWriter.default_url_options[:host].blank?
          options.delete(:original_host)
        end
        rewrite_url_without_proxy(options)
      end
    end
  end
end