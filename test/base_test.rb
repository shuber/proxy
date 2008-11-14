require File.dirname(__FILE__) + '/init'

class BaseTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    ActionController::UrlWriter.default_url_options[:host] = nil
    ActionController::Base.relative_url_root = '/app'
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
  
  def test_should_set_forwarded_host_in_a_named_route
    add_forwarded_host_headers
    get :named_route_action
    assert_equal "http://domain.com/app/normal_action", @response.body
  end
  
  def test_should_restore_the_original_default_host
    ::ActionController::UrlWriter.default_url_options[:host] = 'some-other-domain.com'
    add_forwarded_host_headers
    get :normal_action
    assert_equal "http://domain.com/app/normal_action", @response.body
  end
  
  def test_url_generators_in_views_should_use_forwarded_host
    add_forwarded_host_headers
    get :view_action
    assert_equal "/app/normal_action, http://domain.com/app/normal_action, http://domain.com/app/normal_action, /app/normal_action", @response.body
  end
  
  def test_asset_tag_helpers_should_not_use_forwarded_host
    add_forwarded_host_headers
    get :asset_action
    assert_nil(/domain\.com/.match(@response.body))
  end
  
  def test_should_set_the_session_domain_with_a_forwarded_host
    add_forwarded_host_headers
    get :session_action
    assert_equal '.domain.com', @response.body
  end
  
  def test_should_restore_original_session_domain
    ::ActionController::Base.session_options[:session_domain] = '.example.com'
    add_forwarded_host_headers
    get :session_action
    assert_equal '.domain.com', @response.body
    assert_equal '.example.com', ::ActionController::Base.session_options[:session_domain]
  end
  
  def test_should_restore_original_session_if_exception_is_raised
    ::ActionController::Base.session_options[:session_domain] = '.example.com'
    add_forwarded_host_headers
    assert_raises(RuntimeError) { get :exception_action }
    assert_equal '.example.com', ::ActionController::Base.session_options[:session_domain]
  end
  
  def test_should_restore_original_session_if_redirected
    ::ActionController::Base.session_options[:session_domain] = '.example.com'
    add_forwarded_host_headers
    get :redirect_action
    assert_equal '.example.com', ::ActionController::Base.session_options[:session_domain]
  end
  
  def test_should_restore_original_host_if_exception_is_raised
    ::ActionController::UrlWriter.default_url_options[:host] = 'some-other-domain.com'
    add_forwarded_host_headers
    assert_raises(RuntimeError) { get :exception_action }
    assert_equal 'some-other-domain.com', ::ActionController::UrlWriter.default_url_options[:host]
  end
  
  def test_should_restore_original_host_if_redirected
    ::ActionController::UrlWriter.default_url_options[:host] = 'some-other-domain.com'
    add_forwarded_host_headers
    get :redirect_action
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
  
  def test_should_set_proxy_relative_url_root_in_a_named_route
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/named_route_action'
    @request.env['PATH_INFO'] = '/named_route_action'
    get :named_route_action
    assert_equal "http://#{@request.host}/test/ing/normal_action", @response.body
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
  
  def test_should_restore_relative_url_root_if_exception_is_raised
    add_forwarded_uri_headers
    get :redirect_action
    assert_equal '/app', ActionController::Base.relative_url_root
  end
  
  def test_url_generators_in_views_should_use_forwarded_uri
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/view_action'
    @request.env['PATH_INFO'] = '/view_action'
    get :view_action
    assert_equal "/test/ing/normal_action, http://example.com/test/ing/normal_action, /test/ing/normal_action, /test/ing/normal_action", @response.body
  end
  
  def test_asset_tag_helpers_should_use_forwarded_uri
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/asset_action'
    @request.env['PATH_INFO'] = '/asset_action'
    get :asset_action
    assert !@response.body.scan(/img[^>]+src\="\/test\/ing\/images\/test\.gif"/).empty?
    assert !@response.body.scan(/script[^>]+src\="\/test\/ing\/javascripts\/test\.js"/).empty?
    assert !@response.body.scan(/link[^>]+href\="\/test\/ing\/stylesheets\/test\.css"/).empty?
  end
  
  def test_should_use_forwarded_host_in_a_redirect
    add_forwarded_host_headers
    get :redirect_action
    assert_redirected_to 'http://domain.com/app/normal_action'
  end
  
  def test_should_use_forwarded_host_in_a_redirect_with_named_routes
    add_forwarded_host_headers
    get :redirect_with_named_route_action
    assert_redirected_to 'http://domain.com/app/normal_action'
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