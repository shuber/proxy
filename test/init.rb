$:.reject! { |path| path.include? 'TextMate' }
require 'test/unit'

# Load rubygems
#
require 'rubygems'

# Load ActionPack
#
gem 'actionpack'
require 'action_pack'
require 'action_controller'
require 'action_controller/dispatcher'
require 'action_controller/routing'
require 'action_controller/assertions'
require 'action_controller/test_process'

# Routing
#
class ActionController::Routing::RouteSet
	def append
    yield Mapper.new(self)
    install_helpers
	end
end

# Require the main proxy.rb file
#
require File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'proxy')