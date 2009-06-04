$:.reject! { |path| path.include? 'TextMate' }
require 'test/unit'

# Load rubygems
#
require 'rubygems'

# Load ActionPack
#
args = ['actionpack']
args << ENV['ACTION_PACK_VERSION'] if ENV['ACTION_PACK_VERSION']
gem *args
require 'action_pack'
require 'action_controller'
require 'action_controller/dispatcher'
require 'action_controller/routing'
require 'action_controller/session_management'
require 'action_controller/url_rewriter'
require 'action_controller/test_process'
require 'action_view'

Test::Unit::TestCase.class_eval do
  include ActionController::TestProcess
  
  unless instance_methods.include?('assert_redirected_to')
    def assert_redirected_to(url)
      assert @response.redirect?
      assert_equal url, @response.location
    end
  end
end

# Routing
#
class ActionController::Routing::RouteSet
	def append
    yield Mapper.new(self)
    install_helpers
	end
end

ActionController::Base.session_options.merge! :key => '_proxy_session', :secret => '60447f093cd3f5d57686dd5ca1ced83216c846047db0ec97480a5e85411d9bd41ec5587cc4aafac27a4f0e649f0c628b0955b315856b78787a96168671dc96d4'

# Require the main proxy.rb file
#
require File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'proxy')

# Test controller
#
class TestController < ActionController::Base
  
  def asset_action
    render :inline => '<%= image_tag "test.gif" %>, <%= javascript_include_tag "test" %>, <%= stylesheet_link_tag "test" %>'
  end
  
  def exception_action
    raise 'Uh oh'
  end

  def named_route_action
    render :text => normal_action_url
  end

  def normal_action
    render :text => url_for(:controller => 'test', :action => 'normal_action')
  end
  
  def redirect_action
    redirect_to :action => 'normal_action'
  end
  
  def redirect_with_named_route_action
    redirect_to normal_action_path
  end
  
  def session_action
    render :text => ActionController::Base.session_options[:session_domain]
  end
  
  def view_action
    render :inline => '<%= normal_action_path %>, <%= normal_action_url %>, <%= url_for(:controller => "test", :action => "normal_action") %>, <%= url_for(:controller => "test", :action => "normal_action", :only_path => true) %>'
  end
  
  protected
  
    def rescue_action(e)
      raise e
    end
end

# Test routes
#
ActionController::Routing::Routes.append do |map|
  map.connect 'asset_action', :controller => 'test', :action => 'asset_action'
  map.connect 'exception_action', :controller => 'test', :action => 'exception_action'
  map.connect 'named_route_action', :controller => 'test', :action => 'named_route_action'
  map.connect 'normal_action', :controller => 'test', :action => 'normal_action'
  map.connect 'redirect_action', :controller => 'test', :action => 'redirect_action'
  map.connect 'redirect_with_named_route_action', :controller => 'test', :action => 'redirect_with_named_route_action'
  map.connect 'session_action', :controller => 'test', :action => 'session_action'
  map.connect 'view_action', :controller => 'test', :action => 'view_action'
  map.normal_action 'normal_action', :controller => 'test', :action => 'normal_action'
end