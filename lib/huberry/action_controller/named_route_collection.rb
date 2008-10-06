module Huberry
  module ActionController
    module NamedRouteCollection
      def self.included(base)
        base.class_eval { alias_method_chain :define_url_helper, :proxy }
      end
      
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