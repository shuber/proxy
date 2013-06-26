Gem::Specification.new do |s|
  s.name    = 'hybridgroup-proxy'
  s.version = '2.0.0'
  s.date    = '2013-09-23'
  
  s.summary     = 'A gem/plugin that allows rails applications to respond to multiple domains and proxied requests'
  s.description = 'A gem/plugin that allows rails applications to respond to multiple domains and proxied requests'
  
  s.author   = 'Sean Huber, with changes from Ron Evans and Javier Cervantes'
  s.email    = 'shuber@huberry.com'
  s.homepage = 'http://github.com/hybridgroup/proxy'
  
  s.has_rdoc = false
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.markdown']
  
  s.require_paths = ['lib']
  
  s.files = %w(
    CHANGELOG
    init.rb
    lib/proxy/action_controller/base.rb
    lib/proxy/action_dispatch/request.rb
    lib/proxy.rb
    MIT-LICENSE
    Rakefile
    README.markdown
    test/init.rb
  )
  
  s.test_files = %w(
    test/base_test.rb
    test/proxy_test.rb
    test/request_test.rb
  )
end
