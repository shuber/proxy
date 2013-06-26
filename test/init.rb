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
require 'action_dispatch/routing/route_set'
require 'action_dispatch/routing'
require 'action_dispatch/routing/mapper'
require 'action_controller/metal/session_management'
#require 'action_controller/deprecated/url_rewriter'
require 'action_dispatch/testing/test_process'
require 'action_view'
require 'action_controller/railtie'
Rails.env = 'test'

Test::Unit::TestCase.class_eval do
  include ActionDispatch::TestProcess

  unless instance_methods.include?('assert_redirected_to')
    def assert_redirected_to(url)
      assert @response.redirect?
      assert_equal url, @response.location
    end
  end
end

# Routing
#
#class ActionDispatch::Routing::RouteSet
	##def append
    #yield Mapper.new(self)
    #install_helpers
	#end
#end

#ActionController::Base.session_options.merge! :key => '_proxy_session', :secret => '60447f093cd3f5d57686dd5ca1ced83216c846047db0ec97480a5e85411d9bd41ec5587cc4aafac27a4f0e649f0c628b0955b315856b78787a96168671dc96d4'

module Proxy
  class TestApplication < Rails::Application
    require 'rails/test_help'
  end
end
# Require the main proxy.rb file
#
require File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'proxy')

# Test controller
#
class TestController < ActionController::Base
  include Rails.application.routes.url_helpers

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
    render :text => request.session_options[:session_domain]
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
Proxy::TestApplication.routes.draw do
  match 'asset_action' => 'test#asset_action'
  match 'exception_action' => 'test#exception_action'
  match 'named_route_action' => 'test#named_route_action'
  match 'normal_action' => 'test#normal_action'
  match 'redirect_action' => 'test#redirect_action'
  match 'redirect_with_named_route_action' => 'test#redirect_with_named_route_action'
  match 'session_action' => 'test#session_action'
  match 'view_action' => 'test#view_action'
  match 'normal_action' => 'test#normal_action', :as => :normal_action
end
