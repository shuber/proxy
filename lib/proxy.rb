require 'proxy/action_controller/abstract_request'
require 'proxy/action_controller/base'
require 'proxy/action_controller/named_route_collection'
require 'proxy/action_controller/url_rewriter'
require 'proxy/action_view/url_helper'

ActionController::AbstractRequest = ActionController::Request if defined?(ActionController::Request)
ActionController::AbstractRequest.send :include, Proxy::ActionController::AbstractRequest
ActionController::Base.send :include, Proxy::ActionController::Base
ActionController::Routing::RouteSet::NamedRouteCollection.send :include, Proxy::ActionController::NamedRouteCollection
ActionController::UrlRewriter.send :include, Proxy::ActionController::UrlRewriter
ActionView::Base.send :include, Proxy::ActionView::UrlHelper

unless ActionController::UrlWriter.respond_to?(:default_url_options)
  ActionController::Base.class_eval do
    include ActionController::UrlWriter
    
    def default_url_options_with_backwards_compatibility(*args)
      default_url_options_without_backwards_compatibility
    end
    alias_method_chain :default_url_options, :backwards_compatibility
  end
  
  class << ActionController::UrlWriter
    delegate :default_url_options, :default_url_options=, :to => ::ActionController::Base
  end
end