require File.dirname(__FILE__) + '/init'

class ProxyTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    def @request.host; env['HTTP_X_FORWARDED_HOST'].blank? ? env['HTTP_HOST'] : env['HTTP_X_FORWARDED_HOST'].split(/,\s/).last; end
    @response   = ActionController::TestResponse.new
    @dispatcher = ActionDispatch::Routing::RouteSet::Dispatcher.new({})
    @dispatcher.instance_variable_set('@request', @request)

    Proxy.replace_host_with do |request|
      'replaced.com' if request.host == 'replace-me.com'
    end
  end

  def test_should_not_replace_host
    @request.env['HTTP_HOST'] = 'dont-replace-me.com'
    assert_equal 'dont-replace-me.com', @request.host
    Proxy.send(:before_dispatch, @dispatcher)
    assert_equal 'dont-replace-me.com', @request.host
  end

  def test_should_replace_host
    @request.env['HTTP_HOST'] = 'replace-me.com'
    assert_equal 'replace-me.com', @request.host
    Proxy.send(:before_dispatch, @dispatcher)
    assert_equal 'replaced.com', @request.host
  end

end
