module Huberry
  module Proxy
    module ActionController
      module NamedRouteCollection
        def self.included(base)
          base.class_eval { alias_method_chain :define_url_helper, :proxy }
        end
      
        # Named route url helpers (not path helpers) don't seem to work correctly 
        # with forwarded hosts unless we explicitly set the option:
        #
        #   :only_path => false
        #
        # This method only sets that option if it isn't set already
        def define_url_helper_with_proxy(route, name, kind, options)
          define_url_helper_without_proxy(route, name, kind, options)
          if kind == :url
            selector = url_helper_name(name, kind)
            @module.module_eval do
              define_method "#{selector}_with_proxy" do |*args|
                args << {} unless args.last.is_a? Hash
                args.last[:only_path] ||= false
                send "#{selector}_without_proxy", *args
              end
              alias_method_chain selector, :proxy
            end
          end
        end
      end
    end
  end
end