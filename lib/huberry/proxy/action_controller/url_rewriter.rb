module Huberry
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
          options[:host] ||= ::ActionController::UrlWriter.default_url_options[:host] if options.is_a?(Hash) && !::ActionController::UrlWriter.default_url_options[:host].blank?
          rewrite_url_without_proxy(options)
        end
      end
    end
  end
end