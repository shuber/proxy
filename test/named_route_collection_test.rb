require File.dirname(__FILE__) + '/init'

class NamedRouteCollectionTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    ActionController::UrlWriter.default_url_options[:host] = nil
    ActionController::Base.relative_url_root = nil
  end
  
  def test_should_alias_method_chain_url_helpers
    [ActionController::Base, ActionView::Base].each do |klass|
      assert klass.method_defined?(:normal_action_url_with_proxy)
      assert klass.method_defined?(:normal_action_url_without_proxy)
    end
  end
  
  def test_should_not_alias_method_chain_path_helpers
    [ActionController::Base, ActionView::Base].each do |klass|
      assert !klass.method_defined?(:normal_action_path_with_proxy)
      assert !klass.method_defined?(:normal_action_path_without_proxy)
    end
  end
  
end