require File.dirname(__FILE__) + '/init'

class BaseTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    ActionController::UrlWriter.default_url_options[:host] = nil
    ActionController::Base.relative_url_root = '/app'
    ActionController::Base.proxy_relative_url_root = nil
  end
  
  def test_should_get_normal_action
    get :normal_action
    assert_equal "http://#{@request.host}/normal_action", @response.body
  end
  
  def test_should_set_a_forwarded_host_as_a_default_host
    add_forwarded_host_headers
    get :normal_action
    assert_equal "http://domain.com/app/normal_action", @response.body
  end
  
  def test_should_restore_the_original_default_host
    ::ActionController::UrlWriter.default_url_options[:host] = 'some-other-domain.com'
    add_forwarded_host_headers
    get :normal_action
    assert_equal "http://domain.com/app/normal_action", @response.body
  end
  
  def test_should_set_the_session_domain
    get :normal_action
    assert_equal ".#{@request.host}", ::ActionController.session_options[:session_domain]
  end
  
  def test_should_set_the_session_domain_with_a_forwarded_host
    add_forwarded_host_headers
    get :normal_action
    assert_equal '.domain.com', ::ActionController.session_options[:session_domain]
  end
  
  def test_should_restore_original_host_if_exception_is_raised
    ::ActionController::UrlWriter.default_url_options[:host] = 'some-other-domain.com'
    add_forwarded_host_headers
    assert_raises(RuntimeError) { get :exception_action }
    assert_equal 'some-other-domain.com', ::ActionController::UrlWriter.default_url_options[:host]
  end
  
  def test_should_get_normal_action
    get :normal_action
    assert_equal "http://#{@request.host}/app/normal_action", @response.body
  end
  
  def test_should_swap_relative_url_root
    add_forwarded_uri_headers
    get :normal_action
    assert_equal "http://#{@request.host}/test/ing/normal_action", @response.body
    assert_equal '/app', ActionController::Base.relative_url_root
  end
  
  def test_should_set_proxy_relative_url_root
    add_forwarded_uri_headers
    get :normal_action
    assert_equal '/test/ing', ActionController::Base.proxy_relative_url_root
  end
  
  def test_should_set_original_relative_url_root
    add_forwarded_uri_headers
    get :normal_action
    assert_equal '/app', ActionController::Base.original_relative_url_root
  end
  
  def test_should_restore_relative_url_root_if_exception_is_raised
    add_forwarded_uri_headers
    assert_raises(RuntimeError) { get :exception_action }
    assert_equal '/app', ActionController::Base.relative_url_root
  end
  
  protected
  
    def add_forwarded_host_headers
      @request.env['HTTP_X_FORWARDED_HOST'] = 'domain.com'
    end
  
    def add_forwarded_uri_headers
      @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/normal_action'
      @request.env['PATH_INFO'] = '/normal_action'
    end
  
end