Proxy
=====

A gem/plugin that allows rails applications to dynamically respond to proxied requests by detecting forwarded host/uri headers and setting the session domain, default host, and relative url root. The plugin adds this functionality to calls to url\_for, named route helpers, and view url helpers while still allowing you to specifically set the :host and :only\_path options to override this behavior.

The original session domain, default host, and relative url root will be restored after each request.


Installation
------------

	script/plugin install git://github.com/shuber/proxy.git
	OR
	gem install shuber-proxy --source http://gems.github.com


Usage
-----

Lets say you have a suite of hosted applications all running on the same domain but mounted on different paths. One of them is an order/invoicing application located at:

	http://client.example.com/orders

Imagine you sold an account to a client but the client wants the application to look like its running on his own domain, so they'll set up a proxy so they can access your application at:

	http://clientdomain.com/orders

This plugin will automatically detect this forwarded host and set the session domain and default host (for url generation) accordingly.

Now imagine the client had an existing ordering system already running at /orders, and he wants to slowly migrate his data into your application, so he'll need both applications running for awhile. He wants to keep his original ordering application running at /orders and he wants your application running at:

	http://clientdomain.com/neworders

All the client has to do is proxy /neworders to http://client.example.com/orders and this plugin will automatically detect the forwarded request uri and set the relative url root for your application accordingly. Now whenever urls are generated, they will correctly use /neworders as the relative url root instead of /orders.

Note: this plugin looks for a request header called 'HTTP\_X\_FORWARDED\_URI' to detect the relative root url by default, but this can be overwritten like so:

	ActionController::AbstractRequest.forwarded_uri_header_name = 'SOME_CUSTOM_HEADER_NAME'

You can add that line in environment.rb or an initializer.


Relative Url Root Proxy Setup
-----------------------------

The client's proxy must forward the request uri header in order for this plugin to automatically set the relative url root correctly. Here is how the client would setup a proxy in apache for the example above:

	RewriteRule ^neworders(.*) http://client.example.com/orders$1 [P,E=originalUri:%{REQUEST_URI}]
	RequestHeader append X_FORWARDED_URI %{originalUri}e


Contact
-------

Problems, comments, and suggestions all welcome: [shuber@huberry.com](mailto:shuber@huberry.com)