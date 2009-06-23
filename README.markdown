# Proxy

A gem/plugin that allows rails applications to dynamically respond to multiple domains and proxied requests by detecting forwarded host/uri headers and setting the session domain, default host, and relative url root. The plugin adds this functionality to calls to url\_for, named route helpers, and view url helpers while still allowing you to specifically set the :host and :only\_path options to override this behavior.

The original session domain, default host, and relative url root will be restored after each request.

Requires actionpack >= 2.0.0


## Installation

	script/plugin install git://github.com/shuber/proxy.git
	OR
	gem install shuber-proxy --source http://gems.github.com


## Usage

### Proxied Requests

Let's say you have a suite of hosted applications all running on the same domain but mounted on different paths. One of them is an order/invoicing application located at:

	http://client.example.com/orders

Imagine you sold an account to a client but the client wants the application to look like its running on his own domain, so they'll set up a proxy so they can access your application at:

	http://clientdomain.com/orders

This plugin will automatically detect this forwarded host and set the session domain and default host (for url generation) accordingly.


### Proxied Requests with Custom URIs

Now imagine the client had an existing ordering system already running at /orders, and he wants to slowly migrate his data into your application, so he'll need both applications running for awhile. He wants to keep his original ordering application running at /orders and he wants your application running at:

	http://clientdomain.com/neworders

All the client has to do is proxy /neworders to http://client.example.com/orders and this plugin will automatically detect the forwarded request uri and set the relative url root for your application accordingly. Now whenever urls are generated, they will correctly use /neworders as the relative url root instead of /orders.

Note: this plugin looks for a request header called 'HTTP\_X\_FORWARDED\_URI' to detect the relative root url by default, but this can be overwritten like so:

	ActionController::AbstractRequest.forwarded_uri_header_name = 'SOME_CUSTOM_HEADER_NAME'

You can add that line in environment.rb or an initializer.


#### Relative Url Root Proxy Setup

The client's proxy must forward the request uri header in order for this plugin to automatically set the relative url root correctly. Here is how the client would setup a proxy in apache for the example above:

	RewriteRule ^neworders(.*) http://client.example.com/orders$1 [P,QSA,L,E=originalUri:%{REQUEST_URI}]
	RequestHeader append X_FORWARDED_URI %{originalUri}e e=originalUri


### Multiple Domains

Imagine you have a CMS that hosts multiple client sites. You want your users to manage their sites on your root domain `http://yourcmsapp.com` and you display a site's public content when it's accessed by its subdomain (e.g. `http://cool-site.yourcmsapp.com`). You'll probably be using [subdomain-fu](http://github.com/mbleigh/subdomain-fu) so you can route based on subdomains like:

	ActionController::Routing::Routes.draw do |map|
	  # this routing controller has a before_filter callback that looks up a site by subdomain
	  map.public_page '*path', :controller => 'routing', :conditions => { :subdomain => /^[^\.]+$/ }
	
	  map.with_options :conditions => { :subdomain => nil } do |admin|
	    admin.resource :account, :controller => 'account'
	    admin.resources :sites
	    ...
	  end
	end

Now, it gets tricky if you want `http://cool-site.com` to render `cool-site`'s public content because you can't tell if this request has a subdomain or not. In order for your routes to work, you must have all requests coming in from your domain `yourcmsapp.com`. You can accomplish this by calling the `Proxy.replace_host_with(&block)` method like so:

	# config/initializers/proxy.rb
        
	Proxy.replace_host_with do |request|
	  "#{Site.find_by_domain(request.host).try(:subdomain) || '-INVALID-'}.yourcmsapp.com" unless request.host =~ /(\.|^)yourcmsapp.com$/i
	end

Let's examine what this block is doing:

* First, it checks if the current request's host is already on your domain. If it is, we don't need to do anything, otherwise...
* It checks if a site exists with a domain that matches the current request's host.
* If a site does exist, a new host is returned using the site's `subdomain` with your app domain and everything renders fine, otherwise...
* A fake host is returned (-INVALID-.yourcmsapp.com), and the request 404s once it gets to your `routing` controller and a site can't be found with the subdomain `-INVALID-`

If `nil, false, or an empty string` is returned when you call the `Proxy.replace_host_with` method, the current request's host is not modified. Otherwise, the `HTTP_X_FORWARDED_HOST` request header is set to: `"#{the_original_host}, #{the_new_host}"`. This allows your routes to use your domain when evaluating routing conditions and also allows all of the application's url generators to use the original host.


## Contact

Problems, comments, and suggestions all welcome: [shuber@huberry.com](mailto:shuber@huberry.com)