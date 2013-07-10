require 'proxy/action_controller/base'
require 'proxy/action_dispatch/request'

module Proxy
  class Middleware
    mattr_accessor :replace_host_with_proc
    self.replace_host_with_proc = proc { |request| }

    def self.replace_host_with(&block)
      self.replace_host_with_proc = block
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      request  = Rack::Request.new(env)
      new_host = replace_host_with_proc.call(request)

      if /([^\.]+\.[^\.]+)$/.match(request.host)
        original_host = ".#{$1}"
      else
        original_host = request.host
      end

      env['rack.session.options'][:domain] = original_host
      unless new_host.blank?
        env['HTTP_X_FORWARDED_HOST'] = [request.host, new_host].join(', ')
      end

      @app.call(env)
    end
  end

  class Railtie < Rails::Railtie
    initializer "proxy.initializer" do |app|
      app.config.middleware.use "Proxy::Middleware"
    end
  end
end

ActionDispatch::Request.send :include, Proxy::ActionDispatch::Request
ActionController::Base.send :include, Proxy::ActionController::Base
