require File.dirname(__FILE__) + '/init'

class BaseTest < ActionController::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
  end

  def test_should_get_normal_action
    get :normal_action
    assert_equal "http://#{@request.host}/normal_action", @response.body
  end

  def test_should_set_a_forwarded_host_as_a_default_host
    add_forwarded_host_headers
    get :normal_action
    assert_equal "http://domain.com/normal_action", @response.body
  end

  def test_should_set_forwarded_host_in_a_named_route
    add_forwarded_host_headers
    get :named_route_action
    assert_equal "http://domain.com/normal_action", @response.body
  end

  def test_should_restore_the_original_default_host
    add_forwarded_host_headers
    get :normal_action
    assert_equal "http://example.com/normal_action", @response.body
  end

  def test_url_generators_in_views_should_use_forwarded_host
    add_forwarded_host_headers
    get :view_action
    assert_equal "/normal_action, http://domain.com/normal_action, /normal_action, /normal_action", @response.body
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
    request.session_options[:session_domain] = '.example.com'
    add_forwarded_host_headers
    get :session_action
    assert_equal '.domain.com', @response.body
  end

  def test_should_restore_original_session_domain_with_domain_key
    request.session_options[:domain] = '.example.com'
    add_forwarded_host_headers
    get :session_action
    assert_equal '.domain.com', @response.body
  end

  def test_should_restore_original_session_if_exception_is_raised
    request.session_options[:session_domain] = '.example.com'
    add_forwarded_host_headers
    assert_raises(RuntimeError) { get :exception_action }
    assert_equal '.example.com', request.session_options[:session_domain]
  end

  def test_should_restore_original_session_if_redirected
    request.session_options[:session_domain] = '.example.com'
    add_forwarded_host_headers
    get :redirect_action
    assert_equal '.example.com', request.session_options[:session_domain]
  end

  def test_should_restore_original_host_if_exception_is_raised
    request.host = 'some-other-domain.com'
    add_forwarded_host_headers
    assert_raises(RuntimeError) { get :exception_action }
    assert_equal 'some-other-domain.com', request.host
  end

  def test_should_restore_original_host_if_redirected
    request.host = 'some-other-domain.com'
    add_forwarded_host_headers
    get :redirect_action
    assert_equal 'some-other-domain.com', request.host
  end

  def test_should_use_forwarded_host_in_a_redirect
    add_forwarded_host_headers
    get :redirect_action
    assert_redirected_to 'http://domain.com/normal_action'
  end

  def test_should_use_forwarded_host_in_a_redirect_with_named_routes
    add_forwarded_host_headers
    get :redirect_with_named_route_action
    assert_redirected_to 'http://domain.com/normal_action'
  end

  protected

  def add_forwarded_host_headers
    @request.env['HTTP_X_FORWARDED_HOST'] = 'domain.com'
  end

end
