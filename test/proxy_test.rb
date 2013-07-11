require File.dirname(__FILE__) + '/init'

class ProxyTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @env        = {
      'rack.session.options' => {
        domain: nil
      }
    }
    @app        = Object.new
    def @app.call(env)
      @env = env
    end
    def @request.host
      @env['HTTP_HOST']
    end
    @response   = ActionController::TestResponse.new
  end

  def test_should_not_replace_host
    @request.env['HTTP_HOST'] = 'dont-replace-me.com'
    assert_equal 'dont-replace-me.com', @request.host
    proxy = Proxy::Middleware.new(@app)
    proxy.call(@env)
    assert_equal 'dont-replace-me.com', @request.host
  end

  def test_should_replace_host
    Proxy::Middleware.replace_host_with do |request|
      'replaced.com'
    end
    @request.env['HTTP_HOST'] = 'replace-me.com'
    assert_equal 'replace-me.com', @request.host
    proxy = Proxy::Middleware.new(@app)
    proxy.call(@env)
    assert_equal  'replaced.com', @env["HTTP_X_FORWARDED_HOST"].split(', ').last
  end

end
