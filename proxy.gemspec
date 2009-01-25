Gem::Specification.new do |s|
  s.name    = 'proxy'
  s.version = '1.2.3'
  s.date    = '2009-01-24'
  
  s.summary     = 'A gem/plugin that allows rails applications to dynamically respond to proxied requests'
  s.description = 'A gem/plugin that allows rails applications to dynamically respond to proxied requests by detecting forwarded host/uri headers and setting the session domain, default host, and relative url root'
  
  s.author   = 'Sean Huber'
  s.email    = 'shuber@huberry.com'
  s.homepage = 'http://github.com/shuber/proxy'
  
  s.has_rdoc = false
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.markdown']
  
  s.require_paths = ['lib']
  
  s.files = %w(
    CHANGELOG
    init.rb
    lib/huberry/proxy/action_controller/abstract_request.rb
    lib/huberry/proxy/action_controller/base.rb
    lib/huberry/proxy/action_controller/named_route_collection.rb
    lib/huberry/proxy/action_controller/url_rewriter.rb
    lib/huberry/proxy/action_view/url_helper.rb
    lib/proxy.rb
    MIT-LICENSE
    Rakefile
    README.markdown
  )
  
  s.test_files = %w(
    test/abstract_request_test.rb
    test/base_test.rb
    test/named_route_collection_test.rb
    test/url_helper_test.rb
    test/url_rewriter_test.rb
  )
end