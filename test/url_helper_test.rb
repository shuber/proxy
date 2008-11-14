require File.dirname(__FILE__) + '/init'

class UrlHelperTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    ActionController::UrlWriter.default_url_options[:host] = nil
    ActionController::Base.relative_url_root = nil
  end
  
  def test_should_render_urls_normally
    get :view_action
    assert_equal '/normal_action, http://example.com/normal_action, /normal_action, /normal_action', @response.body
  end
  
  def test_should_render_urls_with_forwarded_hosts_while_respecting_the_only_path_option
    @request.env['HTTP_X_FORWARDED_HOST'] = 'domain.com'
    get :view_action
    assert_equal '/normal_action, http://domain.com/normal_action, http://domain.com/normal_action, /normal_action', @response.body
  end
  
  def test_should_render_urls_with_forwarded_uris
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/view_action'
    @request.env['PATH_INFO'] = '/view_action'
    get :view_action
    assert_equal '/test/ing/normal_action, http://example.com/test/ing/normal_action, /test/ing/normal_action, /test/ing/normal_action', @response.body
  end
  
  def test_should_render_urls_with_forwarded_hosts_and_uris
    @request.env['HTTP_X_FORWARDED_HOST'] = 'domain.com'
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/view_action'
    @request.env['PATH_INFO'] = '/view_action'
    get :view_action
    assert_equal '/test/ing/normal_action, http://domain.com/test/ing/normal_action, http://domain.com/test/ing/normal_action, /test/ing/normal_action', @response.body
  end
  
end