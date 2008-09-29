require File.dirname(__FILE__) + '/init'

class DispatcherTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
  end

  def test_should_get_normal_action
    get :normal_action
    assert_equal 'http://example.com/app/normal_action', @response.body
  end
  
  def test_should_set_a_forwarded_host_as_a_default_host
    @request.env['HTTP_X_FORWARDED_HOST'] = 'some-other-domain.com'
    get :normal_action
    assert_equal 'http://some-other-domain.com/app/normal_action', @response.body
  end
  
  def test_should_restore_the_original_default_host
    @request.env['HTTP_X_FORWARDED_HOST'] = 'some-other-domain.com'
    get :normal_action
    assert_equal 'http://some-other-domain.com/app/normal_action', @response.body
    assert_equal 'example.com', ::ActionController::UrlRewriter.default_url_options[:host]
  end
  
  def test_should_set_the_session_domain
    get :normal_action
    assert_equal '.example.com', ::ActionController.session_options[:session_domain]
  end
  
  def test_should_set_the_session_domain_with_a_forwarded_host
    @request.env['HTTP_X_FORWARDED_HOST'] = 'some-other-domain.com'
    get :normal_action
    assert_equal '.some-other-domain.com', ::ActionController.session_options[:session_domain]
  end
  
end