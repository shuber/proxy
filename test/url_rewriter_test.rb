require File.dirname(__FILE__) + '/init'

class UrlRewriter < ::ActionController::UrlRewriter
  public
    def rewrite_url
      super :action => :normal_action, :controller => :test
    end
end

class UrlRewriterTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    @url_rewriter = UrlRewriter.new(@request, {})
    @dispatcher = ActionController::Dispatcher.new(StringIO.new)
    @dispatcher.instance_variable_set('@request', @request)
    ActionController::UrlWriter.default_url_options[:host] = nil
  end
  
  def test_should_rewrite_normal_action_with_request_host
    assert_equal 'http://example.com/normal_action', @url_rewriter.rewrite_url
  end
  
  def test_should_rewrite_normal_action_with_request_host_if_default_host_is_empty
    ActionController::UrlWriter.default_url_options[:host] = ''
    assert_equal 'http://example.com/normal_action', @url_rewriter.rewrite_url
  end
  
  def test_should_rewrite_normal_action_with_default_host
    ActionController::UrlWriter.default_url_options[:host] = 'test.com'
    assert_equal 'http://test.com/normal_action', @url_rewriter.rewrite_url
  end
  
  def test_should_rewrite_normal_action_with_forwarded_host
    around_dispatcher_callbacks('domain.com') do
      assert_equal 'http://domain.com/normal_action', @url_rewriter.rewrite_url
    end
  end
  
  protected
  
    def around_dispatcher_callbacks(forwarded_host = false)
      @request.env['HTTP_X_FORWARDED_HOST'] = forwarded_host if forwarded_host
      ::ActionController::Dispatcher.before_dispatch_callback_chain.each { |callback| callback.call(@dispatcher) }
      yield if block_given?
      ::ActionController::Dispatcher.after_dispatch_callback_chain.each { |callback| callback.call(@dispatcher) }
    end
  
end