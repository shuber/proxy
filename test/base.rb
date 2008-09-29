require File.dirname(__FILE__) + '/init'

class BaseTest < Test::Unit::TestCase

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
  
  def test_should_set_relative_url_root
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/normal_action'
    get :normal_action
    assert_equal 'http://example.com/test/ing/normal_action', @response.body
  end
  
  def test_should_restore_relative_url_root
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/normal_action'
    get :normal_action
    assert_equal 'http://example.com/test/ing/normal_action', @response.body
    assert_equal '/app', ::ActionController::AbstractRequest.relative_url_root
  end
  
end