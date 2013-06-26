Gem::Specification.new do |s|
  s.name    = 'hybridgroup-proxy'
  s.version = '1.3.6'
  s.date    = '2012-09-08'
  
  s.summary     = 'A gem/plugin that allows rails applications to respond to multiple domains and proxied requests'
  s.description = 'A gem/plugin that allows rails applications to respond to multiple domains and proxied requests'
  
  s.author   = 'Sean Huber, with changes from Ron Evans'
  s.email    = 'shuber@huberry.com'
  s.homepage = 'http://github.com/hybridgroup/proxy'
  
  s.has_rdoc = false
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.markdown']
  
  s.require_paths = ['lib']
  
  s.files = %w(
    CHANGELOG
    init.rb
    lib/proxy/action_controller/base.rb
    lib/proxy/action_dispatch/named_route_collection.rb
    lib/proxy/action_dispatch/request.rb
    lib/proxy/action_view/url_helper.rb
    lib/proxy.rb
    MIT-LICENSE
    Rakefile
    README.markdown
    test/init.rb
  )
  
  s.test_files = %w(
    test/base_test.rb
    test/named_route_collection_test.rb
    test/proxy_test.rb
    test/request_test.rb
    test/url_helper_test.rb
  )
end
