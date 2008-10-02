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
require 'action_controller/assertions'
require 'action_controller/routing'
require 'action_controller/session_management'
require 'action_controller/test_process'
require 'action_controller/url_rewriter'

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

# Test controller
#
class TestController < ActionController::Base
  def exception_action
    raise 'Uh oh'
  end

  def normal_action
    render :text => url_for(:controller => 'test', :action => 'normal_action')
  end
  
  protected
  
    def rescue_action(e)
      raise e
    end
end

# Test routes
#
ActionController::Routing::Routes.append do |map|
  map.connect 'exception_action', :controller => 'test', :action => 'exception_action'
  map.connect 'normal_action', :controller => 'test', :action => 'normal_action'
end