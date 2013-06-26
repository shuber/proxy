require File.dirname(__FILE__) + '/init'

class RequestTest < Test::Unit::TestCase

  def setup
    @request = ActionDispatch::TestRequest.new
    @request.env['HTTP_HOST'] = 'example.com'
  end

  def test_forwarded_hosts_should_be_empty
    assert_equal [], @request.forwarded_hosts
  end

  def test_should_parse_empty_forwarded_hosts_into_an_array
    @request.env['HTTP_X_FORWARDED_HOST'] = ''
    assert_equal [], @request.forwarded_hosts
  end

  def test_should_parse_nil_forwarded_hosts_into_an_array
    @request.env['HTTP_X_FORWARDED_HOST'] = nil
    assert_equal [], @request.forwarded_hosts
  end

  def test_forwarded_host_string_should_be_parsed_into_an_array
    @request.env['HTTP_X_FORWARDED_HOST'] = 'forwarded.com'
    assert_equal ['forwarded.com', 'example.com'], @request.forwarded_hosts
  end

  def test_comma_separated_forwarded_host_string_should_be_parsed_into_an_array
    @request.env['HTTP_X_FORWARDED_HOST'] = 'forwarded.com,something.com, test.com,   testing.com'
    assert_equal ['forwarded.com', 'something.com', 'test.com', 'testing.com'], @request.forwarded_hosts
  end

  def test_forwarded_uris_should_be_empty
    assert_equal [], @request.forwarded_uris
  end

  def test_should_parse_empty_forwarded_uris_into_an_array
    @request.env['HTTP_X_FORWARDED_URI'] = ''
    assert_equal [], @request.forwarded_uris
  end

  def test_should_parse_nil_forwarded_uris_into_an_array
    @request.env['HTTP_X_FORWARDED_URI'] = nil
    assert_equal [], @request.forwarded_uris
  end

  def test_forwarded_uri_string_should_be_parsed_into_an_array
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing'
    assert_equal ['/test/ing'], @request.forwarded_uris
  end

  def test_comma_separated_forwarded_uri_string_should_be_parsed_into_an_array
    @request.env['HTTP_X_FORWARDED_URI'] = '/test/ing,/whoa, /uh/oh,   /mmm/kay'
    assert_equal ['/test/ing', '/whoa', '/uh/oh', '/mmm/kay'], @request.forwarded_uris
  end

  def test_should_be_able_to_use_custom_forwarded_uri_header_name
    @original_header_name = ActionDispatch::Request.forwarded_uri_header_name
    @request.env['HTTP_CUSTOM_FORWARDED_URI'] = '/test/ing'
    ActionDispatch::Request.forwarded_uri_header_name = 'HTTP_CUSTOM_FORWARDED_URI'
    assert_equal ['/test/ing'], @request.forwarded_uris
    ActionDispatch::Request.forwarded_uri_header_name = @original_header_name
  end

end
