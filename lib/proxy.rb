require 'huberry/action_controller/abstract_request'
require 'huberry/action_controller/base'
require 'huberry/action_controller/named_route_collection'
require 'huberry/action_controller/url_rewriter'
require 'huberry/action_view/url_helper'

ActionController::AbstractRequest.send :include, Huberry::ActionController::AbstractRequest
ActionController::Base.send :include, Huberry::ActionController::Base
ActionController::Routing::RouteSet::NamedRouteCollection.send :include, Huberry::ActionController::NamedRouteCollection
ActionController::UrlRewriter.send :include, Huberry::ActionController::UrlRewriter
ActionView::Base.send :include, Huberry::ActionView::UrlHelper