Gem::Specification.new do |s|
  s.name    = 'proxy'
  s.version = '1.3.2'
  s.date    = '2009-06-05'
  
  s.summary     = 'A gem/plugin that allows rails applications to respond to multiple domains and proxied requests'
  s.description = 'A gem/plugin that allows rails applications to respond to multiple domains and proxied requests'
  
  s.author   = 'Sean Huber'
  s.email    = 'shuber@huberry.com'
  s.homepage = 'http://github.com/shuber/proxy'
  
  s.has_rdoc = false
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.markdown']
  
  s.require_paths = ['lib']
  
  s.files = %w(
    CHANGELOG
    init.rb
    lib/proxy/action_controller/abstract_request.rb
    lib/proxy/action_controller/base.rb
    lib/proxy/action_controller/named_route_collection.rb
    lib/proxy/action_controller/url_rewriter.rb
    lib/proxy/action_view/url_helper.rb
    lib/proxy.rb
    MIT-LICENSE
    Rakefile
    README.markdown
    test/init.rb
  )
  
  s.test_files = %w(
    test/abstract_request_test.rb
    test/base_test.rb
    test/named_route_collection_test.rb
    test/proxy_test.rb
    test/url_helper_test.rb
    test/url_rewriter_test.rb
  )
end