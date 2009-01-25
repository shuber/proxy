require 'huberry/proxy/action_controller/abstract_request'
require 'huberry/proxy/action_controller/base'
require 'huberry/proxy/action_controller/named_route_collection'
require 'huberry/proxy/action_controller/url_rewriter'
require 'huberry/proxy/action_view/url_helper'

ActionController::AbstractRequest = ActionController::Request if defined?(ActionController::Request)
ActionController::AbstractRequest.send :include, Huberry::Proxy::ActionController::AbstractRequest
ActionController::Base.send :include, Huberry::Proxy::ActionController::Base
ActionController::Routing::RouteSet::NamedRouteCollection.send :include, Huberry::Proxy::ActionController::NamedRouteCollection
ActionController::UrlRewriter.send :include, Huberry::Proxy::ActionController::UrlRewriter
ActionView::Base.send :include, Huberry::Proxy::ActionView::UrlHelper