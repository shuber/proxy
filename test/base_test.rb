require File.dirname(__FILE__) + '/init'

class BaseTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    ActionController::Base.relative_url_root = '/app'
  end
  
  def test_should_get_normal_action
    get :normal_action
    assert_equal "http://#{@request.host}/app/normal_action", @response.body
  end
  
  def test_should_swap_relative_url_root
    add_request_environment_variables
    get :normal_action
    assert_equal "http://#{@request.host}/test/ing/normal_action", @response.body
    assert_equal '/app', ActionController::Base.relative_url_root
  end
  
  def test_should_set_proxy_relative_url_root
    add_request_environment_variables
    get :normal_action
    assert_equal '/test/ing', ActionController::Base.proxy_relative_url_root
  end
  
  def test_should_set_original_relative_url_root
    add_request_environment_variables
    get :normal_action
    assert_equal '/app',ActionController::Base.original_relative_url_root
  end
  
  protected
  
    def add_request_environment_variables
      @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/normal_action'
      @request.env['PATH_INFO'] = '/normal_action'
    end
  
end