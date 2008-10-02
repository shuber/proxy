require 'huberry/action_controller/dispatcher'
require 'huberry/action_controller/base'
require 'huberry/action_controller/abstract_request'

::ActionController::Dispatcher.send :include, ::Huberry::ActionController::Dispatcher
::ActionController::Base.send :include, ::Huberry::ActionController::Base
::ActionController::AbstractRequest.send :include, ::Huberry::ActionController::AbstractRequest