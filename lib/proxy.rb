require 'huberry/action_controller/dispatcher'
require 'huberry/action_controller/base'

::ActionController::Dispatcher.send :include, ::Huberry::ActionController::Dispatcher
::ActionController::Base.send :include, ::Huberry::ActionController::Base