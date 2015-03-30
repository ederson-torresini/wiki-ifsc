vcl 4.0;

import directors;

backend nginx0_8010 {
	.host = "wiki0";
	.port = "8010";
	.probe = {
		.url = "/wiki/mw-config/images/bullet.gif";
		.interval = 10s;
		.timeout = 2s;
		.window = 5;
		.threshold = 3;
	}
}

backend nginx0_8011 {
	.host = "wiki0";
	.port = "8011";
	.probe = {
		.url = "/wiki/mw-config/images/bullet.gif";
		.interval = 10s;
		.timeout = 2s;
		.window = 5;
		.threshold = 3;
	}
}

backend nginx1_8010 {
	.host = "wiki1";
	.port = "8010";
	.probe = {
		.url = "/wiki/mw-config/images/bullet.gif";
		.interval = 10s;
		.timeout = 2s;
		.window = 5;
		.threshold = 3;
	}
}

backend nginx1_8011 {
	.host = "wiki1";
	.port = "8011";
	.probe = {
		.url = "/wiki/mw-config/images/bullet.gif";
		.interval = 10s;
		.timeout = 2s;
		.window = 5;
		.threshold = 3;
	}
}

sub vcl_init {
	new nginx = directors.hash();
	nginx.add_backend(nginx0_8010, 1.0);
	nginx.add_backend(nginx0_8011, 1.0);
	nginx.add_backend(nginx1_8010, 1.0);
	nginx.add_backend(nginx1_8011, 1.0);
}

sub vcl_recv {
	set req.backend_hint = nginx.backend(req.http.cookie);
}
