require 'proxy/action_controller/base'
require 'proxy/action_dispatch/request'

module Proxy
  mattr_accessor :replace_host_with_proc
  self.replace_host_with_proc = proc { |request| }

  def self.replace_host_with(&block)
    self.replace_host_with_proc = block
  end

  private

    def self.before_dispatch(dispatcher)
      request = dispatcher.instance_variable_get('@request') || dispatcher.instance_variable_get('@env')
      request = ActionDispatch::Request.new(request) if request.is_a?(Hash)
      new_host = replace_host_with_proc.call(request)
      if /([^\.]+\.[^\.]+)$/.match(request.host)
        original_host = ".#{$1}"
      else
        original_host = request.host
      end
      session_options = request.env['rack.session.options']
      request.env['rack.session.options'].merge!(:domain => original_host) if session_options# force cookie that matches original domain without subdomain
      request.env['HTTP_X_FORWARDED_HOST'] = [request.host, new_host].join(', ') unless new_host.blank?
    end
end

ActionDispatch::Callbacks.before do |dispatcher|
  Proxy.send :before_dispatch, dispatcher
end

ActionDispatch::Request = ActionDispatch::Request if defined?(ActionDispatch::Request)
ActionDispatch::Request.send :include, Proxy::ActionDispatch::Request
ActionController::Base.send :include, Proxy::ActionController::Base
