require 'huberry/action_controller/abstract_request'
require 'huberry/action_controller/base'
require 'huberry/action_controller/dispatcher'

::ActionController::AbstractRequest.send :include, ::Huberry::ActionController::AbstractRequest
::ActionController::Base.send :include, ::Huberry::ActionController::Base
::ActionController::Dispatcher.send :include, ::Huberry::ActionController::Dispatcher