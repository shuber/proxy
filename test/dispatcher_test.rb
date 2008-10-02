require File.dirname(__FILE__) + '/init'

class DispatcherTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    @dispatcher = ActionController::Dispatcher.new(StringIO.new)
    @dispatcher.instance_variable_set('@request', @request)
  end

  def test_should_get_normal_action
    around_dispatcher_callbacks do
      get :normal_action
      assert_equal "http://#{@request.host}/normal_action", @response.body
    end
  end
  
  def test_should_set_a_forwarded_host_as_a_default_host
    around_dispatcher_callbacks('domain.com') do
      get :normal_action
      assert_equal "http://domain.com/normal_action", @response.body
    end
  end
  
  def test_should_restore_the_original_default_host
    ::ActionController::UrlWriter.default_url_options[:host] = 'some-other-domain.com'
    around_dispatcher_callbacks('domain.com') do
      get :normal_action
      assert_equal "http://domain.com/normal_action", @response.body
    end
  end
  
  def test_should_set_the_session_domain
    around_dispatcher_callbacks do
      get :normal_action
      assert_equal ".#{@request.host}", ::ActionController.session_options[:session_domain]
    end
  end
  
  def test_should_set_the_session_domain_with_a_forwarded_host
    around_dispatcher_callbacks('domain.com') do
      get :normal_action
      assert_equal '.domain.com', ::ActionController.session_options[:session_domain]
    end
  end
  
  protected
    
    def around_dispatcher_callbacks(forwarded_host = false)
      @request.env['HTTP_X_FORWARDED_HOST'] = forwarded_host if forwarded_host
      
      @original_default_host = ::ActionController::UrlWriter.default_url_options[:host]
      ::ActionController::Dispatcher.before_dispatch_callback_chain.each{ |callback| callback.call(@dispatcher) }
      assert_equal @original_default_host, ::ActionController::UrlWriter.default_url_options[:original_host]
      
      yield if block_given?
      
      ::ActionController::Dispatcher.after_dispatch_callback_chain.each{ |callback| callback.call(@dispatcher) }
      assert_equal ::ActionController::UrlWriter.default_url_options[:original_host], ::ActionController::UrlWriter.default_url_options[:host]
    end
  
end