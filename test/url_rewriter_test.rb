require File.dirname(__FILE__) + '/init'

class UrlRewriter < ::ActionController::UrlRewriter
  public
    def rewrite_url
      super :action => :normal_action, :controller => :test
    end
end

class UrlRewriterTest < Test::Unit::TestCase

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = 'example.com'
    @url_rewriter = UrlRewriter.new(@request, {})
    ActionController::UrlWriter.default_url_options[:host] = nil
    ActionController::Base.relative_url_root = nil
  end
  
  def test_should_rewrite_normal_action_with_request_host
    assert_equal 'http://example.com/normal_action', @url_rewriter.rewrite_url
  end
  
  def test_should_rewrite_normal_action_with_request_host_if_default_host_is_empty
    ActionController::UrlWriter.default_url_options[:host] = ''
    assert_equal 'http://example.com/normal_action', @url_rewriter.rewrite_url
  end
  
  def test_should_rewrite_normal_action_with_default_host
    ActionController::UrlWriter.default_url_options[:host] = 'test.com'
    assert_equal 'http://test.com/normal_action', @url_rewriter.rewrite_url
  end
  
end