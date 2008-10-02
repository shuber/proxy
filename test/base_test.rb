require File.dirname(__FILE__) + '/init'

class BaseTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    @relative_url_root = '/app'
    ActionController::AbstractRequest.relative_url_root = @relative_url_root
  end
  
  def test_should_get_normal_action
    get :normal_action
    assert_equal "http://example.com#{@relative_url_root}/normal_action", @response.body
  end
  
  def test_should_swap_relative_url_root
    add_request_environment_variables
    get :normal_action
    assert_equal 'http://example.com/test/ing/normal_action', @response.body
    assert_equal @relative_url_root, ::ActionController::AbstractRequest.relative_url_root
  end
  
  def test_should_set_original_relative_url_root
    add_request_environment_variables
    get :normal_action
    assert_equal @relative_url_root, @controller.class.original_relative_url_root
  end
  
  protected
  
    def add_request_environment_variables
      @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing/normal_action'
      @request.env['PATH_INFO'] = '/normal_action'
    end
  
end