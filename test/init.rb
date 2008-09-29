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
require 'action_controller/dispatcher'
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

# Set a relative url root
#
ActionController::AbstractRequest.relative_url_root = '/app'

# Test controller
#
class TestController < ActionController::Base
  prepend_before_filter :set_class_relative_url_root, :only => :action_with_relative_url_root
  
  def action_with_relative_url_root
    display
  end
  
  def normal_action
    display
  end
  
  protected
  
    def display
      render :text => url_for(:controller => 'test', :action => 'normal_action')
    end
  
    def rescue_action(e)
      raise e
    end
    
    def set_class_relative_url_root
      self.class.relative_url_root = '/test'
    end
end

# Test routes
#
ActionController::Routing::Routes.append do |map|
  map.connect 'action_with_relative_url_root', :controller => 'test', :action => 'action_with_relative_url_root'
  map.connect 'normal_action', :controller => 'test', :action => 'normal_action'
end